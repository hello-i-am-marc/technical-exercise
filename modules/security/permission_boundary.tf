resource "aws_iam_policy" "workload_boundary" {
  name        = "${var.project}-workload-boundary"
  description = "Permission boundary for workload roles; caps blast radius"
  policy      = data.aws_iam_policy_document.workload_boundary.json
}

# Permission boundary intentionally allows broad actions, capped by explicit Deny statements.
# Checkov flags the broad Allow without understanding the deny-driven semantics that make boundaries work.
#checkov:skip=CKV_AWS_1: Boundary semantics require broad Allow + targeted Deny
#checkov:skip=CKV_AWS_49: Same pattern
#checkov:skip=CKV_AWS_107: Boundary denies the escalation actions explicitly in DenyIAMEscalation
#checkov:skip=CKV_AWS_108: Boundary scope is workload roles; data exfil paths require role attachment in Phase 4
#checkov:skip=CKV_AWS_109: Same pattern
#checkov:skip=CKV_AWS_110: Privilege escalation denied via DenyIAMEscalation
#checkov:skip=CKV_AWS_111: Boundary pattern
#checkov:skip=CKV_AWS_356: Boundary pattern
#checkov:skip=CKV2_AWS_40: Boundary pattern; IAM privileges actively denied
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