#!/usr/bin/env bash
# Destroys the APP server stack (stops AWS charges). Terminate the control node manually in the console.
set -euo pipefail
cd "$(dirname "$0")/../terraform"
read -r -p "Destroy all app infrastructure? (yes/no): " a
[ "$a" = "yes" ] || { echo "Cancelled"; exit 0; }
# S3 bucket is versioned; empty it first so destroy cannot fail
B=$(terraform output -raw backup_bucket 2>/dev/null || true)
if [ -n "$B" ]; then
  aws s3api delete-objects --bucket "$B" --delete "$(aws s3api list-object-versions --bucket "$B" --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json 2>/dev/null || echo '{"Objects":null}')" >/dev/null 2>&1 || true
fi
terraform destroy -auto-approve 2>&1 | tee ../docs/06-terraform-destroy.log | tail -n 8
echo
echo "📸 SCREENSHOT 11: 'Destroy complete! Resources: N destroyed'"
echo "Then terminate control-node in EC2 console (after you push to GitHub)."
