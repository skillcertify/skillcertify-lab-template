#!/bin/bash
docker volume inspect mydata &>/dev/null \
  || { echo '{"pass":false,"message":"Volume mydata not found. Run: docker volume create mydata"}'; exit 0; }
content=$(docker run --rm -v mydata:/data alpine cat /data/hello.txt 2>&1)
[ "$content" = "persistent" ] \
  || { echo "{\"pass\":false,\"message\":\"/data/hello.txt contains '$content', expected 'persistent'\"}"; exit 0; }
echo '{"pass":true,"message":"Volume mydata contains hello.txt with content persistent."}'
