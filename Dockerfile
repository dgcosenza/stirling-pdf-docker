# syntax=docker/dockerfile:1.7
# Hardened Stirling-PDF (Open-Source MIT Core) on Debian 13 (trixie) + Temurin 25 JRE
# Upstream: https://github.com/Stirling-Tools/Stirling-PDF (MIT core flavor only)
# Maintainer: Daniel G. Cosenza from FNX Labs

ARG DEBIAN_BASE=debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0
ARG GRADLE_BASE=gradle:9.7.1-jdk25@sha256:e06837018d077ee7f1218e53499425ca7615702ad58856d980c154caa17eb093
ARG STIRLING_VERSION=3.5.0
ARG NODE_VERSION=24.22.3
ARG NODE_SHA256_AMD64=4f2b175a6d53a5c617a80dba2676238a0688cef28c6da4eba35c7d844e66fcfb
ARG NODE_SHA256_ARM64=6e51a2ada00f0011cc266f65d98922b403d7ad88f809ca2aa615a5fe1ce6e86c
# org.json:json is a transitive dependency of the upstream build and is pinned there to an old release;
# CI resolves the latest Maven Central release every run and overrides it (documented default below).
ARG ORG_JSON_VERSION=20260814
ARG TASK_VERSION=3.54.0
ARG TASK_SHA256_AMD64=fd2ca4e80422699cb8a85888fbca612bbcf3c62f946c1b4bb1ca9fbe9edb1c44
ARG TASK_SHA256_ARM64=126194e3c718cd2cce169b2ce886d493764773727d3102ddde59ccf1d1378849
# Adoptium GPG Key (DEB/RPM Signing Key) <temurin-dev@eclipse.org>
ARG ADOPTIUM_GPG_FPR=3B04D753C9050D9A5D343F39843C48A565F8F04B
ARG IMAGE_CREATED=1970-01-01T00:00:00Z
ARG IMAGE_REVISION=dev
ARG IMAGE_SOURCE=https://github.com/dgcosenza/stirling-pdf-docker

# ---- Stage 1: Build MIT open-source core edition from official release tag ----
FROM ${GRADLE_BASE} AS app-build

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG STIRLING_VERSION
ARG NODE_VERSION
ARG NODE_SHA256_AMD64
ARG NODE_SHA256_ARM64
ARG ORG_JSON_VERSION
ARG TASK_VERSION
ARG TASK_SHA256_AMD64
ARG TASK_SHA256_ARM64
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3002
USER root

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl ca-certificates git xz-utils unzip; \
    update-ca-certificates; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
        amd64) NODE_ARCH="x64"; NODE_SHA="${NODE_SHA256_AMD64}"; TASK_SHA="${TASK_SHA256_AMD64}" ;; \
        arm64) NODE_ARCH="arm64"; NODE_SHA="${NODE_SHA256_ARM64}"; TASK_SHA="${TASK_SHA256_ARM64}" ;; \
        *) echo "ERROR: Unsupported architecture: ${ARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSLo /tmp/node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"; \
    echo "${NODE_SHA}  /tmp/node.tar.xz" | sha256sum -c -; \
    tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1; \
    rm -f /tmp/node.tar.xz; \
    node --version; \
    npm --version; \
    curl -fsSLo /tmp/task.deb "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_${TASK_VERSION}_linux_${ARCH}.deb"; \
    echo "${TASK_SHA}  /tmp/task.deb" | sha256sum -c -; \
    dpkg -i /tmp/task.deb; \
    rm -f /tmp/task.deb; \
    rm -rf /var/lib/apt/lists/*

ENV JDK_JAVA_OPTIONS="--add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED \
  --add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED \
  --add-exports=jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED \
  --add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED \
  --add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED"

WORKDIR /app

RUN set -eux; \
    git clone --depth 1 --branch "v${STIRLING_VERSION}" https://github.com/Stirling-Tools/Stirling-PDF.git /app; \
    # Explicitly purge proprietary/SaaS backend and engine trees before compiling \
    # so only MIT-licensed open-source core code can enter the build artifacts. \
    rm -rf /app/app/proprietary/src /app/app/saas /app/engine; \
    JPDFIUM_PLATFORM="$([ "${TARGETARCH:-amd64}" = "arm64" ] && echo linux-arm64 || echo linux-x64)"; \
    # Upstream resolves org.json:json transitively to an unpatched release. Add it as an \
    # explicit dependency of the core module: Gradle conflict resolution selects the \
    # highest version, so the CI-resolved patched release replaces the transitive one \
    # and is packaged in the bootJar. A Gradle init-script resolutionStrategy override \
    # was tried first but dropped the library from the fat jar, so do not switch back. \
    sed -i "/^dependencies {/a\\    implementation 'org.json:json:${ORG_JSON_VERSION}'" \
        /app/app/core/build.gradle; \
    grep -F "org.json:json:${ORG_JSON_VERSION}" /app/app/core/build.gradle > /dev/null; \
    STIRLING_FLAVOR=core DISABLE_ADDITIONAL_FEATURES=true \
    gradle :stirling-pdf:bootJar :buildRestartHelper \
        -PbuildWithFrontend=true \
        -PbuildWithPortal=false \
        -PjpdfiumPlatforms="${JPDFIUM_PLATFORM}" \
        -x spotlessApply -x spotlessCheck -x test -x sonarqube \
        --no-daemon; \
    ls -lh /app/app/core/build/libs/*.jar /app/build/libs/restart-helper.jar; \
    cp /app/app/core/build/libs/*.jar /app/out-app.jar; \
    # com.posthog.java:posthog:1.2.0 shades org.json 20231013 (CVE-2026-59171) under \
    # com/posthog/java/shaded/org/json and carries stale Maven metadata. Rebuild those \
    # classes from the patched release sources so the fix is real, not just metadata. \
    PATCH_DIR=/tmp/orgjson-patch; \
    mkdir -p "${PATCH_DIR}/src" "${PATCH_DIR}/classes" "${PATCH_DIR}/app" "${PATCH_DIR}/posthog"; \
    curl -fsSLo "${PATCH_DIR}/sources.jar" "https://repo1.maven.org/maven2/org/json/json/${ORG_JSON_VERSION}/json-${ORG_JSON_VERSION}-sources.jar"; \
    unzip -qo "${PATCH_DIR}/sources.jar" -d "${PATCH_DIR}/src"; \
    find "${PATCH_DIR}/src" -name '*.java' -exec sed -i 's/^package org[.]json;/package com.posthog.java.shaded.org.json;/' {} +; \
    javac -nowarn -d "${PATCH_DIR}/classes" $(find "${PATCH_DIR}/src" -name '*.java'); \
    unzip -qo /app/out-app.jar -d "${PATCH_DIR}/app"; \
    POSTHOG_JAR="${PATCH_DIR}/app/BOOT-INF/lib/posthog-1.2.0.jar"; \
    test -f "${POSTHOG_JAR}"; \
    unzip -qo "${POSTHOG_JAR}" -d "${PATCH_DIR}/posthog"; \
    rm -rf "${PATCH_DIR}/posthog/com/posthog/java/shaded/org/json"; \
    mkdir -p "${PATCH_DIR}/posthog/com/posthog/java/shaded/org/json"; \
    cp -a "${PATCH_DIR}/classes/com/posthog/java/shaded/org/json/." "${PATCH_DIR}/posthog/com/posthog/java/shaded/org/json/"; \
    printf '%s\n' "version=${ORG_JSON_VERSION}" 'groupId=org.json' 'artifactId=json' > "${PATCH_DIR}/posthog/META-INF/maven/org.json/json/pom.properties"; \
    grep -F "version=${ORG_JSON_VERSION}" "${PATCH_DIR}/posthog/META-INF/maven/org.json/json/pom.properties" > /dev/null; \
    cp "${PATCH_DIR}/posthog/META-INF/MANIFEST.MF" "${PATCH_DIR}/posthog-manifest.mf"; \
    rm -f "${PATCH_DIR}/posthog/META-INF/MANIFEST.MF"; \
    jar cfm "${POSTHOG_JAR}" "${PATCH_DIR}/posthog-manifest.mf" -C "${PATCH_DIR}/posthog" .; \
    # Update only that one nested jar in the original bootJar; a full re-pack breaks \
    # Spring Boot's nested-jar classloader. \
    mkdir -p "${PATCH_DIR}/staged/BOOT-INF/lib"; \
    cp "${POSTHOG_JAR}" "${PATCH_DIR}/staged/BOOT-INF/lib/posthog-1.2.0.jar"; \
    jar u0f /app/out-app.jar -C "${PATCH_DIR}/staged" BOOT-INF/lib/posthog-1.2.0.jar; \
    echo "Bundled org.json entries:"; \
    jar tf /app/out-app.jar | grep -F 'BOOT-INF/lib/json-' || true; \
    jar tf /app/out-app.jar | grep -F "BOOT-INF/lib/json-${ORG_JSON_VERSION}.jar" > /dev/null; \
    unzip -qo /app/out-app.jar 'BOOT-INF/lib/posthog-1.2.0.jar' -d "${PATCH_DIR}/verify"; \
    unzip -qo "${PATCH_DIR}/verify/BOOT-INF/lib/posthog-1.2.0.jar" 'META-INF/maven/org.json/json/pom.properties' -d "${PATCH_DIR}/verify"; \
    grep -F "version=${ORG_JSON_VERSION}" "${PATCH_DIR}/verify/META-INF/maven/org.json/json/pom.properties" > /dev/null; \
    cp /app/build/libs/restart-helper.jar /app/out-restart-helper.jar; \
    # Guard root-only symlink creation so non-root startup (UID 1000) succeeds cleanly \
    sed -i 's|if \[ -x /scripts/stirling-diagnostics.sh \]|if [ "$(id -u)" -eq 0 ] \&\& [ -x /scripts/stirling-diagnostics.sh ]|' /app/scripts/init-without-ocr.sh; \
    chmod 0755 /app/scripts/*.sh

# ---- Stage 2: Minimal hardened Debian 13 (trixie-slim) + Temurin 25 JRE runtime ----
FROM ${DEBIAN_BASE} AS runtime

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG STIRLING_VERSION
ARG ADOPTIUM_GPG_FPR
ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_SOURCE
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.title="Stirling-PDF (Open-Source Core) on Debian 13 (trixie)" \
      org.opencontainers.image.description="Hardened open-source MIT core Stirling-PDF image on Debian 13 (trixie-slim) with Adoptium Temurin 25 JRE and OCR tools, maintained by Daniel G. Cosenza from FNX Labs." \
      org.opencontainers.image.version="${STIRLING_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/stirling-pdf" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.base.name="debian:trixie-slim" \
      io.github.dgcosenza.stirling_pdf.version="${STIRLING_VERSION}" \
      io.github.dgcosenza.stirling_pdf.flavor="core-mit"

RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gpgv \
        tzdata \
        tini \
        bash \
        procps \
        util-linux \
        fontconfig \
        poppler-utils \
        poppler-data \
        qpdf \
        unpaper \
        pngquant \
        tesseract-ocr \
        tesseract-ocr-eng \
        tesseract-ocr-spa \
        tesseract-ocr-deu \
        tesseract-ocr-fra \
        tesseract-ocr-por \
        tesseract-ocr-osd \
        fonts-dejavu \
        fonts-liberation2 \
        fonts-noto-core \
        libfreetype6 \
        libfontconfig1 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        libxt6 \
        libgomp1; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get install -y --no-install-recommends gpg; \
    \
    install -d -m 0755 /etc/apt/keyrings; \
    KEY_TMP="$(mktemp)"; \
    curl -fsSL "https://packages.adoptium.net/artifactory/api/gpg/key/public" -o "${KEY_TMP}"; \
    FPR="$(gpg --show-keys --with-colons "${KEY_TMP}" | awk -F: '/^fpr:/ { print $10; exit }')"; \
    if [ "${FPR}" != "${ADOPTIUM_GPG_FPR}" ]; then \
        echo "ERROR: Adoptium GPG fingerprint mismatch: got ${FPR}, expected ${ADOPTIUM_GPG_FPR}" >&2; \
        exit 1; \
    fi; \
    gpg --batch --dearmor -o /etc/apt/keyrings/adoptium.gpg "${KEY_TMP}"; \
    chmod 0644 /etc/apt/keyrings/adoptium.gpg; \
    rm -f "${KEY_TMP}"; \
    \
    ARCH="$(dpkg --print-architecture)"; \
    echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb trixie main" \
        > /etc/apt/sources.list.d/adoptium.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends temurin-25-jre; \
    \
    apt-mark auto '.*' > /dev/null; \
    printf '%s\n' "${savedAptMark}" | xargs -r apt-mark manual > /dev/null; \
    apt-mark manual temurin-25-jre > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false gpg; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    \
    groupadd -g 1000 stirlingpdfgroup; \
    useradd -u 1000 -g stirlingpdfgroup -d /home/stirlingpdfuser -s /bin/bash stirlingpdfuser; \
    mkdir -p /home/stirlingpdfuser /configs /logs /customFiles \
        /pipeline/watchedFolders /pipeline/finishedFolders /storage \
        /tmp/stirling-pdf /tmp/stirling-pdf/heap_dumps \
        /usr/share/fonts/opentype/noto /scripts; \
    printf '%s\n' "${STIRLING_VERSION}" > /etc/stirling_version; \
    chown -R 1000:1000 /home/stirlingpdfuser /configs /logs /customFiles \
        /pipeline /storage /tmp/stirling-pdf /usr/share/tesseract-ocr/5/tessdata \
        /usr/share/fonts/opentype/noto /scripts; \
    ln -sf /scripts/stirling-diagnostics.sh /usr/local/bin/diagnostics; \
    ln -sf /scripts/stirling-diagnostics.sh /usr/local/bin/stirling-diagnostics; \
    java -version; \
    qpdf --version; \
    tesseract --version

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    VERSION_TAG="${STIRLING_VERSION}" \
    TESS_BASE_PATH=/usr/share/tesseract-ocr/5/tessdata \
    STIRLING_AOT_ENABLE="false" \
    _JVM_OPTS="-XX:+ExitOnOutOfMemoryError -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/configs/heap_dumps -XX:+UnlockExperimentalVMOptions -XX:+UseShenandoahGC -XX:ShenandoahGCMode=generational -XX:ShenandoahGCHeuristics=adaptive -XX:ShenandoahUncommitDelay=1000 -XX:ShenandoahGuaranteedYoungGCInterval=10000 -XX:ShenandoahGuaranteedOldGCInterval=30000 -XX:+UseCompactObjectHeaders -XX:+UseStringDeduplication -XX:+ExplicitGCInvokesConcurrent -XX:ReservedCodeCacheSize=96m -XX:CICompilerCount=2 -XX:-UseBASE64Intrinsics -Dspring.threads.virtual.enabled=true -Djava.awt.headless=true" \
    JAVA_CUSTOM_OPTS="" \
    HOME=/home/stirlingpdfuser \
    PUID=1000 \
    PGID=1000 \
    UMASK=022 \
    STIRLING_TEMPFILES_DIRECTORY=/tmp/stirling-pdf \
    TMPDIR=/tmp/stirling-pdf \
    TEMP=/tmp/stirling-pdf \
    TMP=/tmp/stirling-pdf \
    DBUS_SESSION_BUS_ADDRESS=/dev/null

COPY --from=app-build --chown=1000:1000 /app/out-app.jar /app.jar
COPY --from=app-build --chown=1000:1000 /app/out-restart-helper.jar /restart-helper.jar
COPY --from=app-build --chown=1000:1000 --chmod=0755 /app/scripts/init.sh /scripts/init.sh
COPY --from=app-build --chown=1000:1000 --chmod=0755 /app/scripts/init-without-ocr.sh /scripts/init-without-ocr.sh
COPY --from=app-build --chown=1000:1000 --chmod=0755 /app/scripts/installFonts.sh /scripts/installFonts.sh
COPY --from=app-build --chown=1000:1000 --chmod=0755 /app/scripts/stirling-diagnostics.sh /scripts/stirling-diagnostics.sh

VOLUME ["/configs", "/logs", "/customFiles", "/usr/share/tesseract-ocr/5/tessdata"]

EXPOSE 8080/tcp

USER stirlingpdfuser:stirlingpdfgroup

ENTRYPOINT ["tini", "--", "/scripts/init.sh"]
CMD []

HEALTHCHECK --interval=30s --timeout=15s --start-period=120s --retries=5 \
    CMD ["curl", "-fsS", "--max-time", "10", "http://127.0.0.1:8080/api/v1/info/status"]
