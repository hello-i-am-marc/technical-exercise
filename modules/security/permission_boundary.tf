resource "aws_iam_policy" "workload_boundary" {
  name        = "${var.project}-workload-boundary"
  description = "Permission boundary for workload roles; caps blast radius"
  policy      = data.aws_iam_policy_document.workload_boundary.json
}

data "aws_iam_policy_document" "workload_boundary" {
  # Allow general read across services
  statement {
    sid       = "AllowGeneralRead"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }

  # Hard-deny VM creation - the lateral movement action the
  # overprivileged Mongo VM role would otherwise enable
  statement {
    sid    = "DenyVMCreation"
    effect = "Deny"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateImage",
      "ec2:CreateLaunchTemplate"
    ]
    resources = ["*"]
  }

  # Hard-deny IAM escalation
  statement {
    sid    = "DenyIAMEscalation"
    effect = "Deny"
    actions = [
      "iam:CreateUser",
      "iam:CreateRole",
      "iam:AttachUserPolicy",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
      "iam:PutUserPolicy"
    ]
    resources = ["*"]
  }

  # Hard-deny actions outside our chosen region
  statement {
    sid    = "DenyOutsideRegion"
    effect = "Deny"
    not_actions = [
      "iam:*",
      "sts:*",
      "s3:ListAllMyBuckets",
      "cloudfront:*",
      "route53:*"
    ]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = [data.aws_region.current.region]
    }
  }
}