resource "aws_inspector2_enabler" "main" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["EC2", "ECR"]

  # Inspector enable can exceed the default Terraform timeout
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}