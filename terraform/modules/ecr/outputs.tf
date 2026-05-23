output "repository_urls" {
  description = "Map of repository names to their URLs"
  value       = { for k, v in aws_ecr_repository.repository : k => v.repository_url }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value       = { for k, v in aws_ecr_repository.repository : k => v.arn }
}

output "repository_names" {
  description = "Map of repository keys to their ECR names"
  value       = { for k, v in aws_ecr_repository.repository : k => v.name }
}

output "registry_id" {
  description = "ECR registry ID (same for all repositories in the account)"
  value       = values(aws_ecr_repository.repository)[0].registry_id
}
