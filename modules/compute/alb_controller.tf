resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }

  depends_on = [aws_eks_node_group.main]
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.0"  # check artifacthub for current; pin for reproducibility
  namespace  = "kube-system"

  set = [
  {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  },
  {
    name  = "serviceAccount.create"
    value = "false"
  },
  {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  },
  {
    name  = "region"
    value = data.aws_region.current.region
  },
  {
    name  = "vpcId"
    value = var.vpc_id
  },
  ]

  depends_on = [
    kubernetes_service_account.alb_controller,
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.alb_controller,
  ]
}