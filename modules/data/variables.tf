variable "project"                       { type = string }
variable "public_subnet_id"              { type = string }
variable "mongo_vm_sg_id"                { type = string }
variable "mongo_vm_instance_profile_name" { type = string }
variable "mongo_vm_role_name"            { type = string }
variable "logs_kms_key_arn"              { type = string }