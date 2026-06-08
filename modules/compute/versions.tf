# modules/compute/versions.tf
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    http = {
      source = "hashicorp/http"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}