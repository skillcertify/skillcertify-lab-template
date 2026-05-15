#!/bin/bash
docker image inspect myapp:latest &>/dev/null \
  || { echo "FAIL: image myapp:latest not found"; exit 1; }
output=$(docker run --rm myapp:latest 2>&1)
echo "$output" | grep -q "Hello from Docker!" \
  || { echo "FAIL: image output was: $output"; exit 1; }
exit 0
