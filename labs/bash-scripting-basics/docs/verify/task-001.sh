#!/bin/bash
[ -f /root/hello.sh ] || { echo '{"pass":false,"message":"File /root/hello.sh not found. Create it first."}'; exit 0; }
chmod +x /root/hello.sh
output=$(bash /root/hello.sh 2>&1)
echo "$output" | grep -q "Hello, World!" || { echo "{\"pass\":false,\"message\":\"Script output was: $output — expected: Hello, World!\"}"; exit 0; }
echo '{"pass":true,"message":"hello.sh prints Hello, World! correctly."}'
