output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate (base64 encoded)"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks.cluster_version
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL for the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = module.eks.oidc_provider_arn
}

output "node_group_name" {
  description = "Name of the EKS node group"
  value       = keys(module.eks.eks_managed_node_groups)[0]
}

output "kyverno_irsa_role_arn" {
  description = "IAM role ARN for Kyverno IRSA"
  value       = aws_iam_role.kyverno.arn
}
