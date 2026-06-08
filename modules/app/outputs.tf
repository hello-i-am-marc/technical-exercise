output "ecr_repository_url"        { value = aws_ecr_repository.app.repository_url }
output "ecr_repository_arn"        { value = aws_ecr_repository.app.arn }
output "container_deploy_role_arn" { value = aws_iam_role.container_deploy.arn }
output "namespace"                 { value = kubernetes_namespace.app.metadata[0].name }