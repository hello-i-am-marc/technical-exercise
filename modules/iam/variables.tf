variable "project" {
  type = string
}

variable "permission_boundary_arn" {
  type        = string
  description = "ARN of the permission boundary from the security module"
}