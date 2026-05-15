#!/bin/bash
[ -f /root/countdown.sh ] || { echo "FAIL: /root/countdown.sh not found"; exit 1; }
chmod +x /root/countdown.sh
output=$(bash /root/countdown.sh 2>&1)
expected=$'5\n4\n3\n2\n1\nGo!'
[ "$output" = "$expected" ] || { echo "FAIL: got: $output"; exit 1; }
exit 0
