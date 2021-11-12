resource "aws_ecr_repository" "service_repository" {
  name = "${var.org_name}/${var.service_name}"

  tags = {
    Name        = "service_repository"
    Environment = "ANZ-Assessment"
    CreatedBy   = "Terraform"
    Source      = "https://github.com/perminder21/ANZ-Assessment/terraform/03-kubernetes/"
  }
}

resource "aws_ecr_repository_policy" "service_repository_policy" {
  repository = aws_ecr_repository.service_repository.name
  policy = templatefile("./templates/ecr_service_policy.tmpl",{})
}

resource "aws_ecr_lifecycle_policy" "foopolicy" {
  repository = aws_ecr_repository.service_repository.name
  policy = templatefile("./templates/ecr_service_lifecycle_policy.tmpl", {untagged_age = 7, max_version_count = 5})
}
