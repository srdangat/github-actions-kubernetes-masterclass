#!/bin/bash
set -e

echo "==============================="
echo "STEP-1: Create VPC using Terraform"
echo "==============================="

cd vpc
terraform init
terraform validate
terraform plan
terraform apply


echo
echo "==============================="
echo "STEP-2: Create EKS Cluster using Terraform"
echo "==============================="

cd ../eks
terraform init
terraform validate
terraform plan
terraform apply

echo
echo "EKS Cluster and VPC creation completed successfully!"