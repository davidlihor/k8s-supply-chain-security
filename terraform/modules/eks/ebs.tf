resource "aws_iam_role" "ebs_csi_role" {
  name = "${var.project_name}-${var.environment}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ebs-csi-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_role.name
}

resource "aws_iam_policy" "ebs_kms_policy" {
  name        = "${var.project_name}-${var.environment}-ebs-kms-policy"
  description = "Allows the EBS driver to use KMS key for decryption"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:CreateGrant",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:ReEncrypt*",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [module.eks.kms_key_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_kms_attach" {
  policy_arn = aws_iam_policy.ebs_kms_policy.arn
  role       = aws_iam_role.ebs_csi_role.name
}

