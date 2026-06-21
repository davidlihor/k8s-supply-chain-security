resource "kubernetes_namespace_v1" "kyverno" {
  metadata {
    name = "kyverno"

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "k8s-supply-chain-security"
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
          create = true
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
        enableDefaultRegistryMutation = true
        excludeKyvernoNamespace = true
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
            failurePolicy  = "Fail"
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

      registryCredHelpers = "default,ecr-login"
    })
  ]
}
