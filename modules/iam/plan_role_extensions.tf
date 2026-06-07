# Extensions to roles managed in /bootstrap/. The plan role lives in bootstrap
# (one-time setup) but its policies are managed here so ongoing changes go
# through the normal pipeline rather than requiring local bootstrap applies.
# aws_iam_role_policy can attach to a role by name string, no need to import
# the role into this module's state.

data "aws_caller_identity" "current" {}

# Terraform refreshes aws_secretsmanager_secret_version by calling GetSecretValue.
# Granted narrowly on project secrets only so plan can detect drift without
# exposing other secrets in the account.
resource "aws_iam_role_policy" "plan_secrets_read" {
  name = "${var.project}-plan-secrets-read"
  role = "${var.project}-gha-plan"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = "arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:${var.project}-*"
    }]
  })
}