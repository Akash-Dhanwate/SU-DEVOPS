#!/usr/bin/env bash
# Terraform apply -> Ansible (twice) -> smoke test. Pauses at each screenshot point.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p docs
export ANSIBLE_NOCOLOR=1 TF_IN_AUTOMATION=1

shot() { echo; echo "📸 ===== SCREENSHOT $1: $2 ====="; read -r -p "   Take it, then press Enter to continue... " _; }

cd terraform
terraform init -input=false 2>&1 | tee ../docs/01-terraform-init.log
terraform validate
terraform plan -input=false 2>&1 | tee ../docs/01-terraform-plan.log | tail -n 15
shot 2 "terraform plan summary (Plan: N to add)"

terraform apply -auto-approve -input=false 2>&1 | tee ../docs/02-terraform-apply.log | tail -n 15
shot 3 "Apply complete + outputs above"
echo "AWS CONSOLE (us-east-1) shots:"
echo "  4: EC2 > Instances (control-node AND student-platform-app-server)"
echo "  5: VPC 10.1.0.0/16 + Security Group inbound rules (22, 80, 8080)"
echo "  6: S3 bucket student-platform-backups-xxxx (Properties > Versioning Enabled)"
read -r -p "   Press Enter when done... " _

cd ../ansible
ansible-galaxy collection install -r requirements.yml | tail -n 3
ansible-playbook playbook.yml 2>&1 | tee ../docs/03-ansible-run1.log | tail -n 12
shot 7 "PLAY RECAP of run 1 (failed=0)"

ansible-playbook playbook.yml 2>&1 | tee ../docs/04-ansible-run2.log | tail -n 12
shot 8 "PLAY RECAP of run 2 -> changed=0 (idempotency proof)"

cd ..
./scripts/smoke_test.sh 2>&1 | tee docs/05-smoke-test.log
shot 9 "smoke test: all 4 gates, UP, students JSON, success"

IP=$(cd terraform && terraform output -raw app_server_public_ip)
echo
echo "Open in your Mac browser:  http://$IP/api/health"
echo "SCREENSHOT 10: browser showing {\"status\":\"UP\"} with the IP in the address bar"
echo "Keep the app up until you have it. Then run: ./scripts/03_destroy.sh"
