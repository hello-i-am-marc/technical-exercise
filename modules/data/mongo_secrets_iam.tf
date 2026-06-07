resource "aws_iam_role_policy" "mongo_vm_secrets" {
  name = "${var.project}-mongo-vm-secrets"
  role = var.mongo_vm_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = aws_secretsmanager_secret.mongo_credentials.arn
      },
      {
        # Secrets Manager calls kms:Decrypt on the principal's behalf when retrieving
        # a CMK-encrypted secret. kms:ViaService condition restricts the decrypt to
        # only happen via Secrets Manager (defense in depth: the role can't directly
        # decrypt arbitrary things with the key).
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = var.logs_kms_key_arn
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}