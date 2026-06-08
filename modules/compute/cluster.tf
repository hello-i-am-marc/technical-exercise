# Public endpoint access enabled with broad CIDR; IAM authentication is the primary control
# Required because CI/CD runners need to manage K8s resources via the cluster API
#trivy:ignore:AVD-AWS-0040
#trivy:ignore:AVD-AWS-0041
resource "aws_eks_cluster" "main" {
  #checkov:skip=CKV_AWS_38:Public endpoint access enabled; IAM auth gates all API calls
  #checkov:skip=CKV_AWS_39:Public CIDR open to enable CI/CD runner access; IAM is the primary security control
  #checkov:skip=CKV_AWS_339:Using current EKS-supported Kubernetes version per var.k8s_version

  name     = "${var.project}-cluster"
  version  = var.k8s_version
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]  # IAM auth is the primary control; CI runner needs network access
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  encryption_config {
    provider {
      key_arn = var.logs_kms_key_arn
    }
    resources = ["secrets"]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Name = "${var.project}-cluster"
  }
}