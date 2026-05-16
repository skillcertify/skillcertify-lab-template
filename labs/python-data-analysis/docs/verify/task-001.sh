#!/bin/bash
[ -f /root/row_count.txt ] || { echo '{"pass":false,"message":"File /root/row_count.txt not found. Save the row count there."}'; exit 0; }
count=$(cat /root/row_count.txt | tr -d '[:space:]')
[[ "$count" =~ ^[0-9]+$ ]] || { echo "{\"pass\":false,\"message\":\"row_count.txt must contain a number, got: '$count'\"}"; exit 0; }
[ "$count" -gt 0 ] || { echo '{"pass":false,"message":"Row count is 0 — make sure the CSV loaded correctly."}'; exit 0; }
echo "{\"pass\":true,\"message\":\"Dataset loaded: $count rows.\"}"
