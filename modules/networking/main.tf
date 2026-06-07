data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Look up Wiz starter VPC by CloudFormation logical-id tag
data "aws_vpc" "main" {
  tags = {
    "aws:cloudformation:logical-id" = "WizlabsVPC"
  }
}

data "aws_subnet" "public_one" {
  tags = {
    "aws:cloudformation:logical-id" = "PublicSubnetOne"
  }
}

data "aws_subnet" "public_two" {
  tags = {
    "aws:cloudformation:logical-id" = "PublicSubnetTwo"
  }
}

data "aws_subnet" "private_one" {
  tags = {
    "aws:cloudformation:logical-id" = "PrivateSubnetOne"
  }
}

data "aws_subnet" "private_two" {
  tags = {
    "aws:cloudformation:logical-id" = "PrivateSubnetTwo"
  }
}