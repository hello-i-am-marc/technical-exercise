output "cloudtrail_bucket" { value = aws_s3_bucket.trail.id }
output "guardduty_detector_id" { value = data.aws_guardduty_detector.existing.id }
output "config_recorder_name" { value = aws_config_configuration_recorder.main.name }
output "permission_boundary_arn" { value = aws_iam_policy.workload_boundary.arn }