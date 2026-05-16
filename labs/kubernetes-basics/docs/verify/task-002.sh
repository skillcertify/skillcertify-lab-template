#!/bin/bash
[ -f /root/service_ip.txt ] || { echo '{"pass":false,"message":"No service IP found. Run: kubectl get svc web -n lab -o jsonpath='\''{.spec.clusterIP}'\'' > /root/service_ip.txt"}'; exit 0; }
ip=$(cat /root/service_ip.txt | tr -d '[:space:]')
[ -n "$ip" ] || { echo '{"pass":false,"message":"service_ip.txt is empty."}'; exit 0; }
kubectl get svc web -n lab >/dev/null 2>&1 || { echo '{"pass":false,"message":"Service \"web\" not found in namespace \"lab\". Run: kubectl expose deployment web --port=80 -n lab"}'; exit 0; }
echo '{"pass":true,"message":"Service \"web\" is exposed and ClusterIP saved."}'
