#!/usr/bin/env bash
# Smoke test for dgcosenza/stirling-pdf image
# Verifies: non-root UID 1000 startup, healthy /api/v1/info/status endpoint,
# web UI HTTP 200, OCR/PDF CLI tools, and negative healthcheck behavior.

set -euo pipefail

IMAGE="${1:-dgcosenza/stirling-pdf:ci-candidate}"
CONTAINER_NAME="stirling-smoke-$$"

cleanup() {
    docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "=== Smoke testing ${IMAGE} ==="
docker run -d --name "${CONTAINER_NAME}" \
    --security-opt no-new-privileges:true \
    -e SYSTEM_DEFAULTLOCALE=en-GB \
    -e SPRINGDOC_APIDOCS_ENABLED=false \
    -e SPRINGDOC_SWAGGERUI_ENABLED=false \
    "${IMAGE}"

echo "Waiting for container healthcheck..."
for i in $(seq 1 90); do
    STATUS="$(docker inspect --format '{{.State.Health.Status}}' "${CONTAINER_NAME}" 2>/dev/null || echo "missing")"
    if [ "${STATUS}" = "healthy" ]; then
        echo "OK: Container status is healthy"
        break
    fi
    if [ "${STATUS}" = "missing" ] || [ "$(docker inspect --format '{{.State.Running}}' "${CONTAINER_NAME}" 2>/dev/null || echo false)" != "true" ]; then
        echo "ERROR: Container exited prematurely"
        docker logs "${CONTAINER_NAME}" || true
        exit 1
    fi
    sleep 2
    if [ "${i}" -eq 90 ]; then
        echo "ERROR: Container did not become healthy within 180s (status=${STATUS})"
        docker logs "${CONTAINER_NAME}" || true
        exit 1
    fi
done

echo "Verifying non-root execution (UID 1000)..."
UID_ACTUAL="$(docker exec "${CONTAINER_NAME}" id -u)"
if [ "${UID_ACTUAL}" != "1000" ]; then
    echo "ERROR: Expected UID 1000, got ${UID_ACTUAL}"
    exit 1
fi
echo "OK: Running as UID ${UID_ACTUAL} (stirlingpdfuser)"

echo "Verifying /api/v1/info/status returns UP..."
STATUS_JSON="$(docker exec "${CONTAINER_NAME}" curl -fsS http://127.0.0.1:8080/api/v1/info/status)"
echo "Status response: ${STATUS_JSON}"
printf '%s' "${STATUS_JSON}" | grep -q '"status":"UP"'
echo "OK: API status is UP"

echo "Verifying web UI returns HTTP 200..."
HTTP_CODE="$(docker exec "${CONTAINER_NAME}" curl -s -o /dev/null -w '%{http_code}' -L http://127.0.0.1:8080/)"
if [ "${HTTP_CODE}" != "200" ]; then
    echo "ERROR: Expected HTTP 200 on /, got ${HTTP_CODE}"
    exit 1
fi
echo "OK: Web UI HTTP ${HTTP_CODE}"

echo "Verifying PDF/OCR runtime tools..."
docker exec "${CONTAINER_NAME}" qpdf --version >/dev/null
docker exec "${CONTAINER_NAME}" tesseract --version >/dev/null
echo "OK: qpdf and tesseract present"

echo "Running negative healthcheck test (stopped server)..."
if docker run --rm --entrypoint curl "${IMAGE}" -fsS --max-time 5 http://127.0.0.1:8080/api/v1/info/status >/dev/null 2>&1; then
    echo "ERROR: Healthcheck unexpectedly passed without Stirling-PDF running"
    exit 1
fi
echo "OK: Negative healthcheck failed as expected"

echo "=== All smoke tests passed for ${IMAGE} ==="
