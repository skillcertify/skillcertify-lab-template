#!/bin/bash
pgrep -f "sleep 9999" &>/dev/null && { echo "FAIL: sleep 9999 is still running"; exit 1; }
exit 0
