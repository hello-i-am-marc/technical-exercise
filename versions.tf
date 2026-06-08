terraform {
  required_version = ">= 1.15.0, < 2.0.0"
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 6.0" }
    random     = { source = "hashicorp/random", version = "~> 3.6" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.30" }
    helm       = { source = "hashicorp/helm", version = "~> 3.0" }
    http       = { source = "hashicorp/http", version = "~> 3.4"}
    tls        = { source = "hashicorp/tls", version = "~> 4.0"}
  }
}