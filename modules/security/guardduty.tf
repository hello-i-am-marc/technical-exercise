# The sandbox came pre-configured with a GuardDuty detector deployed by the
# Wiz starter CloudFormation stack. Only one detector is allowed per account
# per region, so we reference the existing one rather than duplicating.
# Wiz enabled most features; we add only RUNTIME_MONITORING, which the
# starter left disabled.

data "aws_guardduty_detector" "existing" {}

resource "aws_guardduty_detector_feature" "runtime_monitoring" {
  detector_id = data.aws_guardduty_detector.existing.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}