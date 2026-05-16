#!/bin/bash
[ -f /root/bypass_token.txt ] || { echo '{"pass":false,"message":"No token found. Save your JWT to /root/bypass_token.txt after logging in via SQLi."}'; exit 0; }
token=$(cat /root/bypass_token.txt | tr -d '[:space:]')
[ -n "$token" ] || { echo '{"pass":false,"message":"bypass_token.txt is empty."}'; exit 0; }
resp=$(curl -sf http://juice-shop:3000/rest/user/whoami -H "Authorization: Bearer $token" 2>/dev/null)
echo "$resp" | grep -qi "email" || { echo '{"pass":false,"message":"Token is invalid or Juice Shop is unreachable. Get a fresh token and try again."}'; exit 0; }
echo '{"pass":true,"message":"Authentication bypass successful — valid session obtained via SQLi."}'
