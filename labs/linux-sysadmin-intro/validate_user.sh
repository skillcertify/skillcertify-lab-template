#!/bin/bash
id deploy &>/dev/null           || { echo "FAIL: user 'deploy' does not exist"; exit 1; }
[ -d /home/deploy ]             || { echo "FAIL: /home/deploy not found"; exit 1; }
getent passwd deploy | grep -q "/bin/bash" || { echo "FAIL: shell is not /bin/bash"; exit 1; }
getent group sudo | grep -qw deploy        || { echo "FAIL: 'deploy' not in sudo group"; exit 1; }
exit 0
