#!/bin/bash
[ -f /root/admin_token.txt ] || { echo '{"pass":false,"message":"No token found. Save your JWT to /root/admin_token.txt after bypassing login."}'; exit 0; }
token=$(cat /root/admin_token.txt | tr -d '[:space:]')
[ -n "$token" ] || { echo '{"pass":false,"message":"admin_token.txt is empty."}'; exit 0; }
# Verify the token works against the whoami endpoint
resp=$(curl -sf http://juice-shop:3000/rest/user/whoami -H "Authorization: Bearer $token" 2>/dev/null)
echo "$resp" | grep -qi "email" || { echo '{"pass":false,"message":"Token is invalid or Juice Shop is unreachable. Try re-logging in."}'; exit 0; }
echo "$resp" | grep -qi "admin" || { echo '{"pass":false,"message":"Token does not belong to the admin user. Keep trying the SQLi."}'; exit 0; }
echo '{"pass":true,"message":"Admin JWT obtained via SQL injection. Well done!"}'
