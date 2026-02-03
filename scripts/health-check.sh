#!/bin/bash
echo "=== DISK ==="
df -h | awk '$5+0 > 80 {print $0}'

echo
echo "=== DOCKER ==="
docker ps --format "{{.Names}} {{.Status}}"
