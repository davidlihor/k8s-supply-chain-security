variable "project_name" {
  description = "Name of the project, used for naming ECR resources"
  type        = string
}

variable "environment" {
  description = "Environment name, used for naming ECR resources"
  type        = string
}
