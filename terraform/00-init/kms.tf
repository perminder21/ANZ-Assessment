resource "aws_kms_key" "s3-bucket-encryption" {
  description             = "s3 bucket serverside encryption key"
  deletion_window_in_days = 10

  tags = {
    Name        = "s3-bucket-encryptiont"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/00-init/"
  }
}
