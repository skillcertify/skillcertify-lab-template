#!/bin/bash
[ -f /root/configmap_value.txt ] || { echo '{"pass":false,"message":"No value found. Run: kubectl get configmap app-config -n lab -o jsonpath='\''{.data.APP_ENV}'\'' > /root/configmap_value.txt"}'; exit 0; }
val=$(cat /root/configmap_value.txt | tr -d '[:space:]')
[ "$val" = "production" ] || { echo "{\"pass\":false,\"message\":\"Expected APP_ENV=production, got: '$val'. Check your ConfigMap.\"}"; exit 0; }
echo '{"pass":true,"message":"ConfigMap \"app-config\" created with APP_ENV=production."}'
