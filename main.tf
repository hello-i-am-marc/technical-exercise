module "security" {
  source  = "./modules/security"
  project = var.project
}

module "networking" {
  source  = "./modules/networking"
  project = var.project
}

module "iam" {
  source                  = "./modules/iam"
  project                 = var.project
  permission_boundary_arn = module.security.permission_boundary_arn
}

module "data" {
  source                         = "./modules/data"
  project                        = var.project
  public_subnet_id               = module.networking.public_subnet_ids[0]
  mongo_vm_sg_id                 = module.networking.mongo_vm_sg_id
  mongo_vm_instance_profile_name = module.iam.mongo_vm_instance_profile_name
  mongo_vm_role_name             = module.iam.mongo_vm_role_name
  logs_kms_key_arn               = module.security.logs_kms_key_arn
}

module "compute" {
  source             = "./modules/compute"
  project            = var.project
  k8s_version        = var.k8s_version
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  logs_kms_key_arn   = module.security.logs_kms_key_arn
  admin_user_arn     = var.admin_user_arn
  admin_cidr         = var.admin_cidr
}

module "app" {
  source                  = "./modules/app"
  project                 = var.project
  github_owner            = var.github_owner
  github_repo             = var.github_repo
  cluster_name            = module.compute.cluster_name
  cluster_arn             = module.compute.cluster_arn  # needs to be added as a Phase 5 output
  mongo_vm_private_ip     = module.data.mongo_vm_private_ip  # needs to be added as a Phase 4 output
}