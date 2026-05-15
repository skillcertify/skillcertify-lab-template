#!/bin/bash
[ -f /root/calc.sh ] || { echo '{"pass":false,"message":"File /root/calc.sh not found. Create it first."}'; exit 0; }
chmod +x /root/calc.sh
r1=$(bash /root/calc.sh 3 7 2>&1)
[ "$r1" = "10" ] || { echo "{\"pass\":false,\"message\":\"calc.sh 3 7 returned '$r1', expected '10'\"}"; exit 0; }
r2=$(bash /root/calc.sh 10 5 2>&1)
[ "$r2" = "15" ] || { echo "{\"pass\":false,\"message\":\"calc.sh 10 5 returned '$r2', expected '15'\"}"; exit 0; }
echo '{"pass":true,"message":"calc.sh correctly adds two numbers."}'
