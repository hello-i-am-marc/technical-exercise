resource "aws_s3_bucket" "trail" {
  #checkov:skip=CKV_AWS_18:Access logging adds a recursive bucket-for-bucket-logs out of scope for exercise
  #checkov:skip=CKV2_AWS_61:Lifecycle config not needed for 2-week exercise window
  #checkov:skip=CKV2_AWS_62:Event notifications not required for exercise
  #checkov:skip=CKV_AWS_144:Cross-region replication out of scope for single-region exercise
  bucket        = "${var.project}-cloudtrail-${data.aws_caller_identity.current.account_id}-${random_id.suffix.hex}"
  force_destroy = true # exercise teardown convenience
}

resource "aws_s3_bucket_versioning" "trail" {
  bucket = aws_s3_bucket.trail.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail" {
  bucket = aws_s3_bucket.trail.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.logs.arn
    }
    bucket_key_enabled = true # reduces per-object KMS API cost
  }
}

resource "aws_s3_bucket_public_access_block" "trail" {
  bucket                  = aws_s3_bucket.trail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail.id
  policy = data.aws_iam_policy_document.trail_bucket.json
}

data "aws_iam_policy_document" "trail_bucket" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.trail.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
  statement {
    sid       = "AWSCloudTrailWrite"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.trail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}


resource "aws_cloudtrail" "main" {
  #checkov:skip=CKV_AWS_67:Single-region trail is a deliberate cost decision for this exercise
  #checkov:skip=CKV_AWS_252:SNS topic integration optional, not in exercise scope
  #checkov:skip=CKV2_AWS_10:CloudWatch Logs integration out of scope; S3-only trail sufficient for the demo
  name                          = "${var.project}-trail"
  s3_bucket_name                = aws_s3_bucket.trail.id
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = false
  kms_key_id                    = aws_kms_key.logs.arn

  depends_on = [aws_s3_bucket_policy.trail]
}