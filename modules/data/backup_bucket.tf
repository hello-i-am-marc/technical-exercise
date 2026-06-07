resource "random_id" "backup_suffix" {
  byte_length = 4
}

# CMK encryption intentionally omitted; this bucket is publicly readable, encryption-at-rest provides little value
#trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket" "backups" {
  #checkov:skip=CKV_AWS_18:Access logging adds bucket-for-bucket-logs out of scope for exercise
  #checkov:skip=CKV_AWS_21:Versioning intentionally off; backups are append-only by name
  #checkov:skip=CKV_AWS_144:Cross-region replication out of scope for single-region exercise
  #checkov:skip=CKV_AWS_145:KMS encryption omitted by intent; this bucket is publicly readable, encryption-at-rest provides little value
  #checkov:skip=CKV2_AWS_6:Bucket is intentionally publicly readable per exercise; BPA disable is by design
  #checkov:skip=CKV2_AWS_61:Lifecycle config out of scope
  #checkov:skip=CKV2_AWS_62:Event notifications out of scope
  bucket        = "${var.project}-mongo-backups-${data.aws_caller_identity.current.account_id}-${random_id.backup_suffix.hex}"
  force_destroy = true
}

# Block Public Access intentionally disabled per exercise design (the headline misconfig)
#trivy:ignore:AVD-AWS-0086
#trivy:ignore:AVD-AWS-0087
#trivy:ignore:AVD-AWS-0091
#trivy:ignore:AVD-AWS-0093
resource "aws_s3_bucket_public_access_block" "backups" {
  #checkov:skip=CKV_AWS_53:Intentional misconfig per exercise; bucket must be publicly readable
  #checkov:skip=CKV_AWS_54:Same
  #checkov:skip=CKV_AWS_55:Same
  #checkov:skip=CKV_AWS_56:Same
  bucket                  = aws_s3_bucket.backups.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy granting anonymous read + list
data "aws_iam_policy_document" "backups_public" {
  #checkov:skip=CKV_AWS_70:Public read intentional per exercise
  statement {
    sid    = "PublicReadAndList"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.backups.arn,
      "${aws_s3_bucket.backups.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "backups" {
  bucket = aws_s3_bucket.backups.id
  policy = data.aws_iam_policy_document.backups_public.json

  # Must apply AFTER public access block is set to allow public policies
  depends_on = [aws_s3_bucket_public_access_block.backups]
}