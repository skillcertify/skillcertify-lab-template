#!/bin/bash
# Validates: nginx container named 'webserver' running on port 8080

docker ps --filter "name=webserver" --filter "status=running" | grep -q webserver \
  || { echo "FAIL: container 'webserver' is not running"; exit 1; }

curl -sf http://localhost:8080 | grep -qi "nginx" \
  || { echo "FAIL: nginx not responding on port 8080"; exit 1; }

exit 0
