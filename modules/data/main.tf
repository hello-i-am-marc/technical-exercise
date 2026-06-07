data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Latest Ubuntu 22.04 LTS AMI from Canonical
data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}