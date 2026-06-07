# Public IP intentional per exercise; SSH must be exposed to internet
#trivy:ignore:AVD-AWS-0008
resource "aws_instance" "mongo" {
  #checkov:skip=CKV_AWS_88:Public IP is intentional per exercise; SSH must be exposed to internet
  #checkov:skip=CKV_AWS_126:Detailed monitoring out of scope for exercise budget

  ami                    = data.aws_ami.ubuntu_jammy.id
  instance_type          = "t3.medium"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.mongo_vm_sg_id]
  iam_instance_profile   = var.mongo_vm_instance_profile_name
  ebs_optimized          = true

  associate_public_ip_address = true  # intentional per exercise

  # IMDSv2 required — real security control, doesn't undermine the demo
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Encrypted root volume (real fix; orthogonal to the intentional misconfigs)
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    region       = data.aws_region.current.region
    secret_name  = aws_secretsmanager_secret.mongo_credentials.name
    backup_bucket = aws_s3_bucket.backups.id
  })

  user_data_replace_on_change = true

  # SSM agent is included in the Ubuntu 22.04 AMI; no extra install needed
  tags = {
    Name = "${var.project}-mongo-vm"
  }

  depends_on = [
    aws_iam_role_policy.mongo_vm_secrets,
    aws_s3_bucket_policy.backups
  ]
}