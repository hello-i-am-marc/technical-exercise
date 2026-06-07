resource "random_password" "mongo_admin" {
  length  = 32
  special = false  # avoids URL-encoding pain in mongo connection strings
}

resource "aws_secretsmanager_secret" "mongo_credentials" {
  #checkov:skip=CKV2_AWS_57:Rotation out of scope for 2-week exercise
  name        = "${var.project}-mongo-credentials"
  description = "MongoDB admin credentials for the Mongo VM"
  kms_key_id  = var.logs_kms_key_arn
}

resource "aws_secretsmanager_secret_version" "mongo_credentials" {
  secret_id = aws_secretsmanager_secret.mongo_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.mongo_admin.result
  })
}