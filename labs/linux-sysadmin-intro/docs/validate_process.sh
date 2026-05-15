#!/bin/bash
pgrep -f "sleep 9999" &>/dev/null && { echo '{"pass":false,"message":"sleep 9999 is still running. Find its PID with pgrep sleep and kill it with: kill <PID>"}'; exit 0; }
echo '{"pass":true,"message":"No sleep 9999 process running — process was killed successfully."}'
