#!/bin/bash
set -e

echo "==============================="
echo "STEP-1: Destroy EKS Cluster"
echo "==============================="

cd eks
terraform init
terraform destroy

echo "Cleaning up local Terraform cache..."
rm -rf .terraform .terraform.lock.hcl

echo
echo "==============================="
echo "STEP-2: Destroy VPC"
echo "==============================="

cd ../vpc
terraform init
terraform destroy

echo "Cleaning up local Terraform cache..."
rm -rf .terraform .terraform.lock.hcl

echo
echo "EKS Cluster and VPC destroyed successfully!"