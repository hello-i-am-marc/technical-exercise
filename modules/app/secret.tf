data "aws_secretsmanager_secret" "mongo" {
  name = "${var.project}-mongo-credentials"
}

data "aws_secretsmanager_secret_version" "mongo" {
  secret_id = data.aws_secretsmanager_secret.mongo.id
}

locals {
  mongo_creds = jsondecode(data.aws_secretsmanager_secret_version.mongo.secret_string)
  mongo_uri   = "mongodb://${local.mongo_creds.username}:${local.mongo_creds.password}@${var.mongo_vm_private_ip}:27017/exercise?authSource=admin"
}

resource "kubernetes_secret" "mongo" {
  metadata {
    name      = "mongo-credentials"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    MONGO_URI = local.mongo_uri
  }

  type = "Opaque"
}