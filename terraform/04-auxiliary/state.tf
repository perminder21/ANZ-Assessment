terraform {
  backend "s3" {
    bucket = "anz-assessment-terraform-state"
    key    = "state/auxiliary"
    region = "ap-southeast-2"
    encrypt = true
    kms_key_id = "arn:aws:kms:ap-southeast-2:579511882208:key/eb19760e-a0a1-4191-901a-03ae6140fda1"
    dynamodb_table = "terraform-state-locks"
  }
}

data "terraform_remote_state" "init" {
  backend = "local"

  config = {
    path = "../00-init/state/init.tfstate"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "anz-assessment-terraform-state"
    key    = "state/network"
    region = "ap-southeast-2"
    encrypt = true
    kms_key_id = "arn:aws:kms:ap-southeast-2:579511882208:key/eb19760e-a0a1-4191-901a-03ae6140fda1"
    dynamodb_table = "terraform-state-locks"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket = "anz-assessment-terraform-state"
    key    = "state/security"
    region = "ap-southeast-2"
    encrypt = true
    kms_key_id = "arn:aws:kms:ap-southeast-2:579511882208:key/eb19760e-a0a1-4191-901a-03ae6140fda1"
    dynamodb_table = "terraform-state-locks"
  }
}

data "terraform_remote_state" "kubernetes" {
  backend = "s3"
  config = {
    bucket = "anz-assessment-terraform-state"
    key    = "state/kubernetes"
    region = "ap-southeast-2"
    encrypt = true
    kms_key_id = "arn:aws:kms:ap-southeast-2:579511882208:key/eb19760e-a0a1-4191-901a-03ae6140fda1"
    dynamodb_table = "terraform-state-locks"
  }
}
