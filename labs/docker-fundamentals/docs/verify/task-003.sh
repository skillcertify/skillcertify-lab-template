#!/bin/bash
[ -f /root/compose/docker-compose.yml ] \
  || { echo '{"pass":false,"message":"File /root/compose/docker-compose.yml not found. Create it first."}'; exit 0; }
running=$(docker compose -f /root/compose/docker-compose.yml ps --status running --services 2>/dev/null)
echo "$running" | grep -q "web" || { echo '{"pass":false,"message":"Service web is not running. Run: docker compose -f /root/compose/docker-compose.yml up -d"}'; exit 0; }
echo "$running" | grep -q "db"  || { echo '{"pass":false,"message":"Service db is not running. Check docker compose logs for errors."}'; exit 0; }
echo '{"pass":true,"message":"Both web and db services are running via Docker Compose."}'
