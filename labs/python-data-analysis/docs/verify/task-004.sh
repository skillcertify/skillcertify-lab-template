#!/bin/bash
[ -f /root/top_product.txt ] || { echo '{"pass":false,"message":"File /root/top_product.txt not found."}'; exit 0; }
product=$(cat /root/top_product.txt | tr -d '[:space:]')
[ -n "$product" ] || { echo '{"pass":false,"message":"top_product.txt is empty."}'; exit 0; }
# Validate by re-running the check
expected=$(python3 -c "
import pandas as pd, sys
try:
    df = pd.read_csv('/root/sales.csv')
    print(df.groupby('Product')['Quantity'].sum().idxmax())
except Exception as e:
    print('ERROR:' + str(e))
" 2>/dev/null | tr -d '[:space:]')
[ "$product" = "$expected" ] || { echo "{\"pass\":false,\"message\":\"Expected '$expected', got '$product'. Check your groupby logic.\"}"; exit 0; }
echo "{\"pass\":true,\"message\":\"Correct! Best-selling product: $product\"}"
