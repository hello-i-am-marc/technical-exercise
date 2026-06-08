data "aws_iam_policy_document" "container_deploy_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "container_deploy" {
  name               = "${var.project}-gha-container"
  assume_role_policy = data.aws_iam_policy_document.container_deploy_assume.json
}

data "aws_iam_policy_document" "container_deploy" {
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "ECRPushToProjectRepo"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = [aws_ecr_repository.app.arn]
  }
  statement {
    sid    = "EKSDescribeForKubeconfig"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
    ]
    resources = [var.cluster_arn]
  }
}

resource "aws_iam_role_policy" "container_deploy" {
  role   = aws_iam_role.container_deploy.id
  policy = data.aws_iam_policy_document.container_deploy.json
}