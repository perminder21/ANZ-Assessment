#########################
# shared security groups 
# (common access types)
#########################
resource "aws_security_group" "allow_tls_inbound_all" {
  name        = "allow_tls_inbound_all"
  description = "Allow TLS inbound traffic from the internet"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  ingress {
    description = "Allow TLS inbound traffic from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "allow_tls_inbound_all"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

resource "aws_security_group" "service_elb" {
  name        = "service_elb"
  description = "Allow 8080 and 443 inbound traffic from the internet"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  ingress {
    description = "Allow TLS inbound traffic from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow https inbound traffic from the internet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all traffic to private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    // TODO: Not ideal to hard code private CIDRs, but running out of time
    cidr_blocks = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  }

  tags = {
    Name        = "service_elb"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

resource "aws_security_group" "allow_tls_outbound_all" {
  name        = "allow_tls_outbound_all"
  description = "Allow TLS outbound traffic to all of the internet"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  egress {
    description = "Allow TLS outbound traffic to all of the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "allow_tls_outbound_all"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

resource "aws_security_group" "allow_everything_outbound_all" {
  name        = "allow_everything_outbound_all"
  description = "Allow all outbound traffic to all of the internet"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  egress {
    description = "Allow all outbound traffic to all of the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "allow_everything_outbound_all"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

######################################################################
# EKS control plane security
# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
######################################################################
resource "aws_security_group" "eks_control_plane_inbound" {
  name        = "eks_control_plane_inbound"
  description = "Allow inbound traffic to the EKS control plane"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  tags = {
    Name        = "eks_control_plane_inbound"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

#resource "aws_security_group_rule" "eks_control_plane_inbound" {
#  type            = "ingress"
#  description     = "Allow TLS inbound traffic from EKS worker nodes"
 # from_port       = 443
#  to_port         = 443
#  protocol        = "tcp"
#  security_group_id = aws_security_group.eks_control_plane_inbound.id
#  source_security_group_id = "aws_security_group.eks_worker_outbound_to_eks_control_plane.id"
#}

resource "aws_security_group" "eks_control_plane_outbound_to_workers" {
  name        = "eks_control_plane_outbound_to_workers"
  description = "Allow outbound traffic to the EKS worker nodes"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  tags = {
    Name        = "eks_control_plane_outbound_to_workers"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

resource "aws_security_group_rule" "eks_control_plane_outbound_to_workers" {
  type            = "egress"
  description     = "Allow TLS outbound traffic to EKS control plane"
  from_port       = 1025
  to_port         = 65535
  protocol        = "tcp"
  security_group_id = aws_security_group.eks_control_plane_outbound_to_workers.id
  source_security_group_id = aws_security_group.eks_worker_inbound_from_eks_control_plane.id
}
######################################################################
# EKS Worker node security
# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
######################################################################

# Outbound to EKS control plane (Master nodes)
resource "aws_security_group" "eks_worker_outbound_to_eks_control_plane" {
  name        = "eks_worker_outbound_to_eks_control_plane"
  description = "Allow outbound traffic to EKS Control Plane"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  tags = {
    Name        = "eks_worker_outbound_to_eks_control_plane"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

resource "aws_security_group_rule" "eks_worker_outbound_to_eks_control_plane" {
  type            = "egress"
  description     = "Allow TLS outbound traffic to EKS control plane"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  security_group_id = aws_security_group.eks_worker_outbound_to_eks_control_plane.id
  source_security_group_id = aws_security_group.eks_control_plane_inbound.id
}

# Inbound from EKS control plane (Master nodes)
resource "aws_security_group" "eks_worker_inbound_from_eks_control_plane" {
  name        = "eks_worker_inbound_from_eks_control_plane"
  description = "Allow inbound traffic from EKS Control Plane"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  tags = {
    Name        = "eks_worker_inbound_from_eks_control_plane"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

resource "aws_security_group_rule" "eks_worker_tls_inbound_from_eks_control_plane" {
  type            = "ingress"
  description     = "Allow TLS inbound traffic from EKS control plane"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  security_group_id = aws_security_group.eks_worker_inbound_from_eks_control_plane.id
  source_security_group_id = aws_security_group.eks_control_plane_outbound_to_workers.id
}

resource "aws_security_group_rule" "eks_worker_high_range_inbound_from_eks_control_plane" {
  type            = "ingress"
  description     = "Allow high range inbound traffic from EKS control plane"
  from_port       = 1025
  to_port         = 65535
  protocol        = "tcp"
  security_group_id = aws_security_group.eks_worker_inbound_from_eks_control_plane.id
  source_security_group_id = aws_security_group.eks_control_plane_outbound_to_workers.id
}

# Inbound from ELB
resource "aws_security_group" "eks_worker_inbound_from_service_elb" {
  name        = "eks_worker_inbound_from_service_elb"
  description = "Allow inbound traffic from service ELB"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  tags = {
    Name        = "eks_worker_inbound_from_service_elb"
    "kubernetes.io/cluster/anz_assessment" = "owned"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

resource "aws_security_group_rule" "eks_worker_all_inbound_from_service_elb" {
  type            = "ingress"
  description     = "Allow inbound traffic from service ELB"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  security_group_id = aws_security_group.eks_worker_inbound_from_service_elb.id
  source_security_group_id = aws_security_group.service_elb.id
}

# Allow inter-worker node communication for services to be able to talk to each other
resource "aws_security_group" "eks_worker_to_eks_worker" {
  name        = "eks_worker_to_eks_worker"
  description = "Allow inbound traffic from EKS Control Plane"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  tags = {
    Name        = "eks_worker_to_eks_worker"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/02-security/"
  }
}

resource "aws_security_group_rule" "eks_worker_tls_to_eks_worker" {
  type              = "ingress"
  description       = "Allow TLS inbound traffic from EKS worker nodes"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_worker_to_eks_worker.id
  self              = true
}

resource "aws_security_group_rule" "eks_worker_high_range_to_eks_worker" {
  type              = "ingress"
  description       = "Allow TLS inbound traffic from EKS worker nodes"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_worker_to_eks_worker.id
  self              = true
}
