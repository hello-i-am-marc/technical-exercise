resource "aws_guardduty_detector" "main" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}

# EKS Audit Log Monitoring (free, baseline)
resource "aws_guardduty_detector_feature" "eks_audit_logs" {
  detector_id = aws_guardduty_detector.main.id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

# Runtime Monitoring covers EC2 + ECS + EKS (supersedes EKS_RUNTIME_MONITORING).
# Auto-deploys agent on EKS nodes; EC2 agent must be installed manually.
resource "aws_guardduty_detector_feature" "runtime_monitoring" {
  detector_id = aws_guardduty_detector.main.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}