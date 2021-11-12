resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/anz_assessment/cluster"
  retention_in_days = 14

  tags = {
    Name        = "eks_logs"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/03-kubernetes/"
  }
}
