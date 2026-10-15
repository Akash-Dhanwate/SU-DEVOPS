#!/usr/bin/env bash
# One-shot: Terraform provision -> Ansible configure (run twice to prove idempotency)
set -euo pipefail
cd "$(dirname "$0")/.."

(cd terraform && terraform init -input=false && terraform validate && terraform apply -auto-approve)

cd ansible
ansible-galaxy collection install -r requirements.yml
echo "=== Ansible run 1 ===";  ansible-playbook playbook.yml
echo "=== Ansible run 2 (expect changed=0) ==="; ansible-playbook playbook.yml
