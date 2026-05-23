locals {
  repositories = toset([
    "${var.project_name}-${var.environment}-backend",
    "${var.project_name}-${var.environment}-frontend"
  ])
}