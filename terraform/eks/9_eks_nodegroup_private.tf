# Launch Template to ensure EC2 instances get tags
resource "aws_launch_template" "private_nodes_lt" {
  name_prefix = "${local.name}-private-ng-lt-"

  # Do not set image_id so EKS can provide the correct AMI for the managed node group

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name        = "${local.name}-private-ng"
      Environment = var.environment_name
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.tags, {
      Name        = "${local.name}-private-ng-root"
      Environment = var.environment_name
    })
  }

  # Root volume configuration
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }
}

# EKS Managed Node Group - Private Subnets
resource "aws_eks_node_group" "private_nodes" {

  # The name of the EKS cluster this node group belongs to
  cluster_name = aws_eks_cluster.main.name

  # Logical name for this node group in the EKS cluster
  node_group_name = "${local.name}-private-ng"

  # IAM role that EC2 worker nodes will assume
  node_role_arn = aws_iam_role.eks_nodegroup_role.arn

  # Subnets where the worker nodes will be launched (typically private subnets)
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # Instance types for the nodes (e.g., t3.medium, m5.large)
  instance_types = var.node_instance_types

  # Choose between ON_DEMAND or SPOT capacity types
  capacity_type = var.node_capacity_type

  ami_type = "AL2023_x86_64_STANDARD"

  # Use a launch template so EC2 instances inherit tags defined here
  launch_template {
    id      = aws_launch_template.private_nodes_lt.id
    version = aws_launch_template.private_nodes_lt.latest_version
  }

  # Configure auto-scaling limits and defaults
  scaling_config {

    # Desired number of nodes when the node group is created
    desired_size = var.desired_size

    # Minimum number of nodes allowed
    min_size = var.min_size

    # Maximum number of nodes the group can scale to
    max_size = var.max_size
  }

  # Set the max percentage of nodes that can be unavailable during update
  update_config {
    max_unavailable_percentage = 33
  }

  # Force node group update when EKS AMI version changes
  force_update_version = true

  # Apply labels to each EC2 instance for easier scheduling and management in Kubernetes
  labels = {
    "env" = var.environment_name
  }

  # Tags for the node group
  tags = merge(var.tags, {

    # Standard EC2 name tag
    Name = "${local.name}-private-ng"

    # Logical environment (e.g., dev, prod)
    Environment = var.environment_name
  })

  # Ensure IAM role policies are attached before creating the node group
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy
  ]
}