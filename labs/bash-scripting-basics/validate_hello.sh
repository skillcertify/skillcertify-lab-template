#!/bin/bash
[ -f /root/hello.sh ] || { echo "FAIL: /root/hello.sh not found"; exit 1; }
chmod +x /root/hello.sh
output=$(bash /root/hello.sh 2>&1)
echo "$output" | grep -q "Hello, World!" || { echo "FAIL: got: $output"; exit 1; }
exit 0
