#!/bin/bash
# Validates: user 'deploy' exists with home dir and sudo group

id deploy &>/dev/null || { echo "FAIL: user 'deploy' does not exist"; exit 1; }
[ -d /home/deploy ]   || { echo "FAIL: /home/deploy not found"; exit 1; }
getent group sudo | grep -qw deploy || { echo "FAIL: 'deploy' not in sudo group"; exit 1; }
exit 0
