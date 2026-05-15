#!/bin/bash
[ -f /root/countdown.sh ] || { echo '{"pass":false,"message":"File /root/countdown.sh not found. Create it first."}'; exit 0; }
chmod +x /root/countdown.sh
output=$(bash /root/countdown.sh 2>&1)
expected=$'5\n4\n3\n2\n1\nGo!'
[ "$output" = "$expected" ] || { echo "{\"pass\":false,\"message\":\"Output was: $(echo $output | tr '\n' '|') — expected: 5|4|3|2|1|Go!\"}"; exit 0; }
echo '{"pass":true,"message":"Countdown script works correctly."}'
