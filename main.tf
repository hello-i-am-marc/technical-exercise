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