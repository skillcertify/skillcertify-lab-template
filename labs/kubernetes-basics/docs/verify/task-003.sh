#!/bin/bash
[ -f /root/replicas.txt ] || { echo '{"pass":false,"message":"No replica count found. Run: kubectl get deployment web -n lab -o jsonpath='\''{.status.readyReplicas}'\'' > /root/replicas.txt"}'; exit 0; }
count=$(cat /root/replicas.txt | tr -d '[:space:]')
[ "$count" -ge 4 ] 2>/dev/null || { echo "{\"pass\":false,\"message\":\"Expected 4 ready replicas, got: $count. Run: kubectl scale deployment web --replicas=4 -n lab and wait for pods to be Ready.\"}"; exit 0; }
echo '{"pass":true,"message":"Deployment scaled to 4 replicas successfully."}'
