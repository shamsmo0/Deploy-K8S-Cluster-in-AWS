#!/bin/bash
# ============================================================
# deploy.sh — Full deployment script
# Run this from the project root: bash deploy.sh
# ============================================================

set -e  

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   K8s on AWS — Full Deployment Script  ${NC}"
echo -e "${GREEN}========================================${NC}"

# ─── Check prerequisites ─────────────────────────────────────
echo -e "\n${YELLOW}[1/5] Checking prerequisites...${NC}"

command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform not found. Install it first.${NC}"; exit 1; }
command -v ansible   >/dev/null 2>&1 || { echo -e "${RED}Ansible not found. Install it first.${NC}"; exit 1; }
command -v aws       >/dev/null 2>&1 || { echo -e "${RED}AWS CLI not found. Install it first.${NC}"; exit 1; }

aws sts get-caller-identity >/dev/null 2>&1 || { echo -e "${RED}AWS credentials not configured. Run 'aws configure' first.${NC}"; exit 1; }

echo -e "${GREEN}All prerequisites OK.${NC}"

# ─── Terraform ───────────────────────────────────────────────
echo -e "\n${YELLOW}[2/5] Running Terraform...${NC}"
cd terraform/

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

echo -e "\n${YELLOW}[3/5] Exporting Ansible inventory from Terraform outputs...${NC}"
terraform output -raw ansible_inventory > ../ansible/inventory.ini
echo -e "${GREEN}Inventory written to ansible/inventory.ini${NC}"

MASTER_IP=$(terraform output -raw master_public_ip)
cd ..

# ─── Wait for SSH ────────────────────────────────────────────
echo -e "\n${YELLOW}[4/5] Waiting for SSH to be ready on all nodes (up to 3 minutes)...${NC}"
sleep 30

KEY_FILE=$(grep 'private_key_file' ansible/ansible.cfg | awk -F'=' '{print $2}' | xargs)
for i in {1..18}; do
  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "$KEY_FILE" ec2-user@"$MASTER_IP" "echo ok" 2>/dev/null && break
  echo "  Waiting... attempt $i/18"
  sleep 10
done

# ─── Ansible ─────────────────────────────────────────────────
echo -e "\n${YELLOW}[5/5] Running Ansible playbooks...${NC}"
cd ansible/
ansible all -i inventory.ini -m ping
ansible-playbook -i inventory.ini site.yml

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}   Deployment Complete!                  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nTo access your cluster:"
echo -e "  ssh -i $KEY_FILE ec2-user@$MASTER_IP"
echo -e "  kubectl get nodes"
