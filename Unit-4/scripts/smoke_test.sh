#!/usr/bin/env bash
# Gate 1-4 validation. Save output: ./scripts/smoke_test.sh | tee smoke-test.log
set -uo pipefail
cd "$(dirname "$0")/../terraform"
IP=$(terraform output -raw app_server_public_ip)
KEY=${KEY:-$HOME/.ssh/student-aws-key}
echo "Target: $IP  ($(date -u))"

echo "--- Gate 1: Network & OS";  nc -zv -w 5 "$IP" 22
ssh -o StrictHostKeyChecking=no -i "$KEY" ubuntu@"$IP" uptime
echo "--- Gate 2: Daemons";       ssh -i "$KEY" ubuntu@"$IP" "systemctl is-active docker nginx"
echo "--- Gate 3: Container";     ssh -i "$KEY" ubuntu@"$IP" "docker ps --filter name=student-app --format '{{.Status}}'"
echo "--- Gate 4: API"
curl -sf "http://$IP/api/health" | jq .status
curl -sf "http://$IP/api/students" | jq .
curl -sf -X POST "http://$IP/api/marks" -H 'Content-Type: application/json' \
     -d '{"student_id":1,"subject":"DevOps","marks":92}' | jq .
