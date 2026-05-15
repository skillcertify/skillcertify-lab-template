#!/bin/bash
docker volume inspect mydata &>/dev/null \
  || { echo "FAIL: volume 'mydata' not found"; exit 1; }
content=$(docker run --rm -v mydata:/data alpine cat /data/hello.txt 2>&1)
[ "$content" = "persistent" ] \
  || { echo "FAIL: /data/hello.txt contains '$content', expected 'persistent'"; exit 1; }
exit 0
