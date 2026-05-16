#!/bin/bash
result=$(kubectl get deployment web -n lab -o json 2>/dev/null)
[ -n "$result" ] || { echo '{"pass":false,"message":"Deployment \"web\" not found in namespace \"lab\". Run: kubectl create deployment web --image=nginx:alpine --replicas=2 -n lab"}'; exit 0; }
replicas=$(echo "$result" | grep -o '"replicas":[0-9]*' | head -1 | grep -o '[0-9]*')
[ "$replicas" -ge 2 ] 2>/dev/null || { echo "{\"pass\":false,\"message\":\"Deployment exists but has $replicas replica(s). Scale to at least 2: kubectl scale deployment web --replicas=2 -n lab\"}"; exit 0; }
echo '{"pass":true,"message":"Deployment \"web\" is running with 2+ replicas."}'
