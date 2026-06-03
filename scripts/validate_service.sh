#!/bin/bash
# validate_service.sh - ValidateService lifecycle hook
# Verifies the application is healthy by checking the /health endpoint
# Retries every 5 seconds with a 30-second total timeout

set -e

HEALTH_URL="http://localhost:3000/health"
TIMEOUT=30
INTERVAL=5
ELAPSED=0

echo "Starting health check validation..."
echo "URL: ${HEALTH_URL}"
echo "Timeout: ${TIMEOUT}s, Interval: ${INTERVAL}s"

while [ $ELAPSED -lt $TIMEOUT ]; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" || true)

  if [ "$HTTP_CODE" = "200" ]; then
    echo "Health check passed - received HTTP 200 after ${ELAPSED}s"
    exit 0
  fi

  echo "Waiting for application to become healthy... (${ELAPSED}s elapsed, HTTP status: ${HTTP_CODE})"
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "ERROR: Health check failed - no HTTP 200 response after ${TIMEOUT}s"
exit 1
