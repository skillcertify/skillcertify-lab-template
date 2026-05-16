#!/bin/bash
docker ps --filter "name=webserver" --filter "status=running" | grep -q webserver \
  || { echo '{"pass":false,"message":"Container webserver is not running. Run: docker run -d --name webserver -p 8080:80 nginx:alpine"}'; exit 0; }
curl -sf http://localhost:8080 | grep -qi "nginx" \
  || { echo '{"pass":false,"message":"Nginx is not responding on port 8080. Check the port mapping with: docker ps"}'; exit 0; }
echo '{"pass":true,"message":"Container webserver is running and responding on port 8080."}'
