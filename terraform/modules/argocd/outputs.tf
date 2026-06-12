output "argocd_release_name" {
  description = "Helm release name"
  value       = helm_release.argocd.name
}

output "argocd_chart_version" {
  description = "Installed Argo CD chart version"
  value       = helm_release.argocd.version
}
