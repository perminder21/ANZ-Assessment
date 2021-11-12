resource "aws_s3_bucket" "log_bucket" {
  bucket = "anz-assessment-logs"
  acl    = "log-delivery-write"

  tags = {
    Name        = "anz-assessment-logs"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/00-init/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "aws_kms_key.s3-bucket-encryption.arn"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "anz-assessment-terraform-state"
  depends_on = [
    aws_s3_bucket.log_bucket,
  ]
  acl    = "private"
  force_destroy = true
  tags = {
    Name        = "anz-assessment-terraform-state"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/00-init/"
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "aws_kms_key.s3-bucket-encryption.arn"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
