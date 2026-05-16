#!/bin/bash
[ -f /root/disk_report.txt ] || { echo '{"pass":false,"message":"File /root/disk_report.txt not found. Run: df -h > /root/disk_report.txt"}'; exit 0; }
grep -q "Filesystem" /root/disk_report.txt || { echo '{"pass":false,"message":"File does not look like df -h output. Run: df -h > /root/disk_report.txt"}'; exit 0; }
echo '{"pass":true,"message":"Disk report saved to /root/disk_report.txt successfully."}'
