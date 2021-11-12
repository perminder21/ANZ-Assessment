# IAM Role for EKS Cluster (Control plane)
resource "aws_iam_role" "control_plane_role" {
  name = "control_plane_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "EKSServiceAssumeRole"
    }
  ]
}
EOF

  tags = {
    Name        = "control_plane_role"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

resource "aws_iam_role_policy_attachment" "control_plane_role_AmazonEKSServicePolicy_policy_attach" {
  role       = aws_iam_role.control_plane_role.name
  policy_arn = data.aws_iam_policy.AmazonEKSServicePolicy.arn
}

resource "aws_iam_role_policy_attachment" "control_plane_role_AmazonEKSClusterPolicy_policy_attach" {
  role       = aws_iam_role.control_plane_role.name
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
}

# IAM Role for EKS Worker node

resource "aws_iam_role" "eks_worker_node_role" {
  name = "eks_worker_node_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_instance_profile" "eks_worker_node_instance_profile" {
  name = "eks_worker_node_instance_profile"
  role = aws_iam_role.eks_worker_node_role.name
}


resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKS_CNI_Policy" {
  policy_arn = data.aws_iam_policy.AmazonEKS_CNI_Policy.arn
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
  role       = aws_iam_role.eks_worker_node_role.name
}

# Setup aws owned managed policies as data sources to reference in the role
# policy attachments
data "aws_iam_policy" "AmazonEKSServicePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
