resource "kubernetes_namespace_v1" "kyverno" {
  metadata {
    name = "kyverno"

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "supply-chain-security-pipeline"
    }
  }
}

resource "helm_release" "kyverno" {
  name       = "kyverno"
  namespace  = kubernetes_namespace_v1.kyverno.metadata[0].name
  repository = "https://kyverno.github.io/kyverno"
  chart      = "kyverno"
  version    = var.kyverno_chart_version
  timeout    = 600

  values = [
    yamlencode({
      admissionController = {
        replicas = 3

        serviceAccount = {
          annotations = {
            "eks.amazonaws.com/role-arn" = var.kyverno_irsa_role_arn
          }
        }

        container = {
          resources = {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }

      config = {
        webhooks = [
          {
            namespaceSelector = {
              matchExpressions = [
                {
                  key      = "kubernetes.io/metadata.name"
                  operator = "NotIn"
                  values   = ["kyverno", "kube-system"]
                }
              ]
            }
            timeoutSeconds = 30
          }
        ]
      }

      backgroundController = {
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }

      cleanupController = {
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }

      reportsController = {
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }

      features = {
        policyExceptions = {
          enabled = true
        }
      }
    })
  ]
}
