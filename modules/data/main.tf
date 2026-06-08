data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Ubuntu 20.04 LTS focal AMI from June 2023 — intentionally outdated per exercise requirement
# Deprecated by Canonical (standard support ended April 2025) but still launchable
data "aws_ami" "ubuntu_focal" {
  owners = ["099720109477"]  # Canonical

  filter {
    name   = "image-id"
    values = ["ami-0efd657a42099f98f"]
  }
}