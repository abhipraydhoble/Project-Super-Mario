# -------------------------
# IAM Role for EKS Cluster
# -------------------------

# Create an IAM assume role policy document for EKS cluster
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    # Allow EKS service (eks.amazonaws.com) to assume the role
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    # Allow STS assume role action
    actions = ["sts:AssumeRole"]
  }
}

# Create IAM Role for EKS Cluster
resource "aws_iam_role" "example" {
  name               = "eks-cluster-cloud"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach AmazonEKSClusterPolicy to the IAM Role
# This policy allows the cluster to manage AWS resources
resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.example.name
}

# -------------------------
# Networking Setup
# -------------------------

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get public subnets from the default VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -------------------------
# EKS Cluster Setup
# -------------------------

resource "aws_eks_cluster" "example" {
  name     = "EKS_CLOUD"
  role_arn = aws_iam_role.example.arn

  # Attach cluster to VPC subnets
  vpc_config {
    subnet_ids = data.aws_subnets.public.ids
  }

  # Ensure IAM Role permissions are created before the cluster
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
  ]
}

# -------------------------
# IAM Role for Node Group
# -------------------------

# Create IAM Role for EKS Node Group (EC2 Instances)
resource "aws_iam_role" "example1" {
  name = "eks-node-group-cloud"

  # Allow EC2 instances to assume the role
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach worker node policies required for Node Group
# 1. AmazonEKSWorkerNodePolicy → Allows worker nodes to join the cluster
resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example1.name
}

# 2. AmazonEKS_CNI_Policy → Allows networking (VPC CNI plugin)
resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example1.name
}

# 3. AmazonEC2ContainerRegistryReadOnly → Allows pulling container images from ECR
resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example1.name
}

# -------------------------
# EKS Node Group Setup
# -------------------------

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "Node-cloud"
  node_role_arn   = aws_iam_role.example1.arn
  subnet_ids      = data.aws_subnets.public.ids

  # Auto-scaling configuration for node group
  scaling_config {
    desired_size = 1  # Default number of nodes
    max_size     = 2  # Maximum number of nodes
    min_size     = 1  # Minimum number of nodes
  }

  # EC2 instance type for worker nodes
  instance_types = ["c7i-flex.large"]

  # Ensure IAM Role policies are created before node group
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}
