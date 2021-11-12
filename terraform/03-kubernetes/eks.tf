module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "anz_assessment"
  cluster_version = "1.21"
#  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  subnets         = data.terraform_remote_state.network.outputs.private_subnets 

  tags = {
    Name        = "eks-cluster"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/03-kubernetes/"
  }

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id 
  workers_group_defaults = {
    ami = "ami-0ce4af3cb3eb8aea4"
    key_name = "worker_node_keypair"
    root_volume_type = "gp2"
    root_volume_size = "50"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "m5.large" 
      ami                           = "ami-0ce4af3cb3eb8aea4"
      key_name                      = "worker_node_keypair"
      asg_desired_capacity          = 1
      min_capacity                  = 1
      max_capacity                  = 5
      
      additional_security_group_ids = list(
        data.terraform_remote_state.security.outputs.eks_control_plane_inbound.id,
        data.terraform_remote_state.security.outputs.eks_control_plane_outbound_to_workers.id)
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

