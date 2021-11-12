variable "service_name" {
  description = "Name of the service. To be used for naming the ECR repository"
  default = "web-app"
}

variable "org_name" {
  description = "Prefix to use for ECR names. images will be found under org_name/service_name:tag"
  default     = "anz-assessment"
}
