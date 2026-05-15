#!/bin/bash
[ -f /root/leaked_email.txt ] || { echo '{"pass":false,"message":"No email found. Save the leaked email to /root/leaked_email.txt"}'; exit 0; }
email=$(cat /root/leaked_email.txt | tr -d '[:space:]')
echo "$email" | grep -qE ".+@.+\..+" || { echo "{\"pass\":false,\"message\":\"'$email' does not look like a valid email address.\"}"; exit 0; }
echo '{"pass":true,"message":"API authorization bypass successful — user data leaked."}'
