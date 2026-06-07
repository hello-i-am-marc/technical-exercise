resource "aws_iam_role_policy" "mongo_vm_secrets" {
  name = "${var.project}-mongo-vm-secrets"
  role = var.mongo_vm_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.mongo_credentials.arn
    }]
  })
}