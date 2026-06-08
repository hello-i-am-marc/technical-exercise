# Grant your local IAM user cluster-admin access
resource "aws_eks_access_entry" "admin_user" {
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = var.admin_user_arn
  type              = "STANDARD"
  kubernetes_groups = []
}

resource "aws_eks_access_policy_association" "admin_user" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.admin_user.principal_arn

  access_scope {
    type = "cluster"
  }
}

data "aws_iam_role" "plan" {
  name = "${var.project}-gha-plan"
}

resource "aws_eks_access_entry" "plan_role" {
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = data.aws_iam_role.plan.arn
  type              = "STANDARD"
  kubernetes_groups = []
}

resource "aws_eks_access_policy_association" "plan_role_view" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = aws_eks_access_entry.plan_role.principal_arn

  access_scope {
    type = "cluster"
  }
}
