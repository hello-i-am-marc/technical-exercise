resource "aws_eks_access_entry" "container_deploy" {
  cluster_name      = var.cluster_name
  principal_arn     = aws_iam_role.container_deploy.arn
  type              = "STANDARD"
  kubernetes_groups = []
}

# Grant cluster-admin so the workflow can apply any K8s manifest in the app namespace
resource "aws_eks_access_policy_association" "container_deploy" {
  cluster_name  = var.cluster_name
  policy_arn    = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.container_deploy.arn

  access_scope {
    type       = "namespace"
    namespaces = [kubernetes_namespace.app.metadata[0].name]
  }
}