#!/bin/bash
id deploy &>/dev/null || { echo '{"pass":false,"message":"User deploy does not exist. Run: useradd -m -s /bin/bash deploy"}'; exit 0; }
[ -d /home/deploy ] || { echo '{"pass":false,"message":"Home directory /home/deploy not found. Run: useradd -m deploy"}'; exit 0; }
getent passwd deploy | grep -q "/bin/bash" || { echo '{"pass":false,"message":"Shell is not /bin/bash. Run: usermod -s /bin/bash deploy"}'; exit 0; }
getent group sudo | grep -qw deploy || { echo '{"pass":false,"message":"User deploy is not in the sudo group. Run: usermod -aG sudo deploy"}'; exit 0; }
echo '{"pass":true,"message":"User deploy created correctly with home dir, bash shell, and sudo access."}'
