module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10"

  name               = "${var.project_name}-${var.environment}-eks"
  kubernetes_version = var.cluster_version
  enable_irsa        = true

  endpoint_public_access  = true
  endpoint_private_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  create_kms_key                  = true
  kms_key_description             = "KMS key for EKS secrets encryption"
  kms_key_deletion_window_in_days = 7
  enable_kms_key_rotation         = true

  create_cloudwatch_log_group = true
  enabled_log_types           = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  iam_role_use_name_prefix = false
  iam_role_name            = "${var.project_name}-${var.environment}-cluster-role"

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
      pod_identity_association = [
        {
          role_arn        = aws_iam_role.ebs_csi_role.arn
          service_account = "ebs-csi-controller-sa"
        }
      ]
    }
  }

  eks_managed_node_groups = {
    main = {
      name             = "${var.project_name}-${var.environment}-nodes"
      use_name_prefix  = false
      ami_type         = "AL2023_x86_64_STANDARD"
      instance_types   = var.node_instance_types
      capacity_type    = "ON_DEMAND"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      iam_role_use_name_prefix = false
      iam_role_name            = "${var.project_name}-${var.environment}-node-role"

      labels = {
        role        = "worker"
        environment = var.environment
      }

      tags = {
        Name = "${var.project_name}-${var.environment}-node-group"
      }
    }
  }

  access_entries = {
    github_actions = {
      kubernetes_groups = []
      principal_arn     = var.github_actions_role_arn
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eks"
  }
}

resource "aws_iam_role" "kyverno" {
  name = "${var.project_name}-${var.environment}-kyverno-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider}:aud" = "sts.amazonaws.com"
            "${local.oidc_provider}:sub" = "system:serviceaccount:kyverno:kyverno-admission-controller"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-kyverno-irsa"
  }
}

resource "aws_iam_role_policy" "kyverno_ecr" {
  name = "${var.project_name}-${var.environment}-kyverno-ecr-policy"
  role = aws_iam_role.kyverno.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ]
        Resource = "*"
      }
    ]
  })
}
