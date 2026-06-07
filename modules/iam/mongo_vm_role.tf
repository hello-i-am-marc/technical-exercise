data "aws_iam_policy_document" "mongo_vm_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mongo_vm" {
  name                 = "${var.project}-mongo-vm"
  assume_role_policy   = data.aws_iam_policy_document.mongo_vm_assume.json
  permissions_boundary = var.permission_boundary_arn
}

# Overprivileged inline policy by exercise design
data "aws_iam_policy_document" "mongo_vm_inline" {
  #checkov:skip=CKV_AWS_1:Intentionally overprivileged per exercise; capped by permission boundary
  #checkov:skip=CKV_AWS_49:Same
  #checkov:skip=CKV_AWS_107:Same; boundary denies the exfil paths in Phase 2.6
  #checkov:skip=CKV_AWS_108:Same; boundary denies the credentials exposure paths
  #checkov:skip=CKV_AWS_109:Same
  #checkov:skip=CKV_AWS_111:Same
  #checkov:skip=CKV_AWS_356:Same
  # Broad EC2 actions including instance creation (the intended lateral movement path)
  statement {
    sid       = "BroadEC2"
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }
  # S3 access for the backup script
  statement {
    sid    = "S3Backup"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:CreateBucket",
      "s3:PutBucketPolicy",
      "s3:PutBucketAcl"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "mongo_vm_inline" {
  name   = "${var.project}-mongo-vm-inline"
  role   = aws_iam_role.mongo_vm.id
  policy = data.aws_iam_policy_document.mongo_vm_inline.json
}

resource "aws_iam_instance_profile" "mongo_vm" {
  name = "${var.project}-mongo-vm"
  role = aws_iam_role.mongo_vm.name
}