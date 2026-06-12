resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = var.argocd_chart_version
  create_namespace = true

  set = [
    {
      name  = "server.extraArgs"
      value = "{--insecure}"
    }
  ]
}
