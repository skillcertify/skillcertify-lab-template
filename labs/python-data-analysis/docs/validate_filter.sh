#!/bin/bash
[ -f /root/north_count.txt ] || { echo '{"pass":false,"message":"File /root/north_count.txt not found."}'; exit 0; }
count=$(cat /root/north_count.txt | tr -d '[:space:]')
[[ "$count" =~ ^[0-9]+$ ]] || { echo "{\"pass\":false,\"message\":\"north_count.txt must contain a number, got: '$count'\"}"; exit 0; }
expected=$(python3 -c "
import pandas as pd
df = pd.read_csv('/root/sales.csv')
print(len(df[df['Region'] == 'North']))
" 2>/dev/null | tr -d '[:space:]')
[ "$count" = "$expected" ] || { echo "{\"pass\":false,\"message\":\"Expected $expected North rows, got $count. Check your filter condition.\"}"; exit 0; }
echo "{\"pass\":true,\"message\":\"Correct! $count rows with Region=North.\"}"
