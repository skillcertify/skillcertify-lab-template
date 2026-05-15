#!/bin/bash
[ -f /root/calc.sh ] || { echo "FAIL: /root/calc.sh not found"; exit 1; }
chmod +x /root/calc.sh
result=$(bash /root/calc.sh 3 7 2>&1)
[ "$result" = "10" ] || { echo "FAIL: calc.sh 3 7 returned '$result', expected '10'"; exit 1; }
result2=$(bash /root/calc.sh 10 5 2>&1)
[ "$result2" = "15" ] || { echo "FAIL: calc.sh 10 5 returned '$result2', expected '15'"; exit 1; }
exit 0
