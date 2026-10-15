# Student Record & Academic Platform - Terraform + Ansible on AWS
Run on a control EC2 (Ubuntu 22.04):
```
./scripts/01_setup.sh      # install tools, AWS creds, SSH key
./scripts/02_run_all.sh    # terraform + ansible x2 + smoke test (pauses for screenshots)
./scripts/03_destroy.sh    # tear down app stack
./scripts/04_git_push.sh   # push to GitHub
```
