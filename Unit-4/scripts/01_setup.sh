#!/usr/bin/env bash
# Run ON the control EC2 (Ubuntu 22.04). Installs tools, configures AWS, creates SSH key + tfvars.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p docs
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a

echo ">>> [1/5] Base packages"
sudo apt update -y
sudo apt install -y curl wget unzip jq git netcat-openbsd gnupg ca-certificates

echo ">>> [2/5] AWS CLI v2"
if ! command -v aws >/dev/null; then
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -q -o /tmp/awscliv2.zip -d /tmp && sudo /tmp/aws/install --update
  rm -rf /tmp/aws /tmp/awscliv2.zip
fi

echo ">>> [3/5] Terraform (direct binary, works on any Ubuntu release)"
if ! command -v terraform >/dev/null; then
  TFV=1.9.8
  curl -s -o /tmp/tf.zip "https://releases.hashicorp.com/terraform/${TFV}/terraform_${TFV}_linux_amd64.zip"
  unzip -q -o /tmp/tf.zip -d /tmp && sudo mv /tmp/terraform /usr/local/bin/terraform && rm -f /tmp/tf.zip
fi

echo ">>> [4/5] Ansible"
if ! command -v ansible >/dev/null; then
  if ! sudo apt install -y ansible; then
    echo "apt ansible failed, falling back to pipx"
    sudo apt install -y pipx python3-venv
    pipx install --include-deps ansible
    export PATH="$PATH:$HOME/.local/bin"
    grep -q '.local/bin' ~/.bashrc || echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
  fi
fi

echo ">>> [5/5] AWS credentials, SSH key, tfvars"
if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "Enter your AWS keys (region us-east-1, output json):"
  aws configure
fi
if [ ! -f ~/.ssh/student-aws-key ]; then
  mkdir -p ~/.ssh
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/student-aws-key -N "" -C "devops@student-platform" -q
fi
chmod 400 ~/.ssh/student-aws-key
MYIP=$(curl -s https://checkip.amazonaws.com | tr -d '\n')
echo "ssh_allowed_cidr = \"${MYIP}/32\"" > terraform/terraform.tfvars
echo "tfvars -> $(cat terraform/terraform.tfvars)"

{
  echo "# $(date -u)"
  aws --version; terraform -version | head -1; ansible --version | head -1
  aws sts get-caller-identity
} 2>&1 | tee docs/00-tool-versions.log

echo
echo "=============================================="
echo "SCREENSHOT 1: the tool versions + AWS identity above"
echo "Next: ./scripts/02_run_all.sh"
echo "=============================================="
