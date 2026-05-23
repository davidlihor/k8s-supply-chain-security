module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  public_subnets  = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                                            = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-eks" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                                   = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-eks" = "shared"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
