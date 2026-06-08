data "aws_eks_cluster_auth" "main" {
  name = module.compute.cluster_name
}

provider "kubernetes" {
  host                   = module.compute.cluster_endpoint
  cluster_ca_certificate = base64decode(module.compute.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes = {
    host                   = module.compute.cluster_endpoint
    cluster_ca_certificate = base64decode(module.compute.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}