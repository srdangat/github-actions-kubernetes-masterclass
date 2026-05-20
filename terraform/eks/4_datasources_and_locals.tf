locals {
  # Environment name such as dev, staging, prod (from variable)
  environment = var.environment_name # Example: "dev"

  # Standardized naming prefix based on environment and cluster name
  name = "${local.environment}-${var.cluster_name}"

  # Full EKS cluster name used for resource naming and tagging
  eks_cluster_name = local.name
}