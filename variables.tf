variable "project" {
  type    = string
  default = "tech-exercise"
}

variable "k8s_version" {
  type    = string
  default = "1.33"
  description = "EKS Kubernetes version"
}

variable "admin_user_arn" {
  type        = string
  description = "IAM user ARN to grant cluster-admin via EKS access entries"
}

variable "admin_cidr" {
  type        = string
  description = "Your current public IP in CIDR form (e.g., 1.2.3.4/32) for EKS public endpoint access"
}

variable "github_owner" {
  type        = string
  description = "GitHub username/org that owns the repo"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}