#!/usr/bin/env bash
# Pushes the project to GitHub. Create an EMPTY repo on github.com first.
set -euo pipefail
cd "$(dirname "$0")/.."
read -r -p "Git user name: " N; read -r -p "Git email: " E
read -r -p "Repo URL (https://github.com/<you>/student-platform-iac.git): " URL
git config --global user.name "$N"; git config --global user.email "$E"
[ -d .git ] || git init -q
git add .
echo "--- files being committed (no .tfstate / keys / tfvars should appear) ---"
git status --short
read -r -p "Looks safe? Enter to push, Ctrl+C to abort " _
git commit -q -m "Terraform + Ansible automation for Student Record Platform" || true
git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin "$URL"
echo "Username = your GitHub username, Password = your Personal Access Token"
git push -u origin main
