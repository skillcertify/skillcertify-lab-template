#!/bin/bash
[ -f /root/disk_report.txt ] || { echo "FAIL: /root/disk_report.txt not found"; exit 1; }
grep -q "Filesystem" /root/disk_report.txt || { echo "FAIL: file does not look like df output"; exit 1; }
exit 0
