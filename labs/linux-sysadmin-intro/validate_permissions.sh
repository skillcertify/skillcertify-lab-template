#!/bin/bash
[ -f /opt/app/config.env ] || { echo "FAIL: /opt/app/config.env not found"; exit 1; }
perms=$(stat -c "%a" /opt/app/config.env)
[ "$perms" = "640" ] || { echo "FAIL: permissions are $perms, expected 640"; exit 1; }
exit 0
