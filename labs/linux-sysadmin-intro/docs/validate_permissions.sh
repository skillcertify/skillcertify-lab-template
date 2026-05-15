#!/bin/bash
[ -f /opt/app/config.env ] || { echo '{"pass":false,"message":"File /opt/app/config.env not found. Run: mkdir -p /opt/app && touch /opt/app/config.env"}'; exit 0; }
perms=$(stat -c "%a" /opt/app/config.env)
[ "$perms" = "640" ] || { echo "{\"pass\":false,\"message\":\"Permissions are $perms, expected 640. Run: chmod 640 /opt/app/config.env\"}"; exit 0; }
echo '{"pass":true,"message":"File /opt/app/config.env has correct permissions (640)."}'
