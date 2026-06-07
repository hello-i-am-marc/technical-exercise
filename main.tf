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