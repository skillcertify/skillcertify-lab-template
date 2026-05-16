#!/bin/bash
[ -f /root/monthly_revenue.csv ] || { echo '{"pass":false,"message":"File /root/monthly_revenue.csv not found. Save the grouped revenue there."}'; exit 0; }
rows=$(python3 -c "
import pandas as pd, sys
try:
    df = pd.read_csv('/root/monthly_revenue.csv')
    cols = df.columns.str.lower().tolist()
    if 'month' not in cols or 'revenue' not in cols:
        print('MISSING_COLS')
    else:
        print(len(df))
except Exception as e:
    print('ERROR')
" 2>/dev/null)
[ "$rows" = "MISSING_COLS" ] && { echo '{"pass":false,"message":"monthly_revenue.csv must have columns: Month, Revenue"}'; exit 0; }
[ "$rows" = "ERROR" ] && { echo '{"pass":false,"message":"Could not read monthly_revenue.csv as a valid CSV file."}'; exit 0; }
[ "$rows" -gt 0 ] 2>/dev/null || { echo '{"pass":false,"message":"monthly_revenue.csv is empty."}'; exit 0; }
echo "{\"pass\":true,\"message\":\"Monthly revenue CSV saved with $rows months.\"}"
