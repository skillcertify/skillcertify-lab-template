#!/bin/bash
docker image inspect myapp:latest &>/dev/null \
  || { echo '{"pass":false,"message":"Image myapp:latest not found. Run: docker build -t myapp:latest /root/myapp/"}'; exit 0; }
output=$(docker run --rm myapp:latest 2>&1)
echo "$output" | grep -q "Hello from Docker!" \
  || { echo "{\"pass\":false,\"message\":\"Image output was: $output — expected: Hello from Docker!\"}"; exit 0; }
echo '{"pass":true,"message":"Image myapp:latest built and prints Hello from Docker! correctly."}'
