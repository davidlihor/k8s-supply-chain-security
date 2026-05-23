locals {
  oidc_provider     = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_provider_arn = module.eks.oidc_provider_arn
}
