#!/bin/bash
[ -f /root/compose/docker-compose.yml ] \
  || { echo "FAIL: /root/compose/docker-compose.yml not found"; exit 1; }
running=$(docker compose -f /root/compose/docker-compose.yml ps --status running --services 2>/dev/null)
echo "$running" | grep -q "web" || { echo "FAIL: 'web' service not running"; exit 1; }
echo "$running" | grep -q "db"  || { echo "FAIL: 'db' service not running"; exit 1; }
exit 0
