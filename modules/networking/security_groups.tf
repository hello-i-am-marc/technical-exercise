# Mongo VM SG: SSH from internet (intentional), Mongo only from private subnet CIDRs
resource "aws_security_group" "mongo_vm" {
  name        = "${var.project}-mongo-vm"
  description = "Mongo VM: SSH exposed to internet by exercise design; Mongo port restricted to private subnets"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "mongo_ssh" {
  #checkov:skip=CKV_AWS_24:SSH from 0.0.0.0/0 is intentional per exercise requirements
  security_group_id = aws_security_group.mongo_vm.id
  description       = "SSH from internet (intentional misconfig)"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "mongo_db_from_private_one" {
  security_group_id = aws_security_group.mongo_vm.id
  description       = "MongoDB from EKS private subnet one"
  ip_protocol       = "tcp"
  from_port         = 27017
  to_port           = 27017
  cidr_ipv4         = data.aws_subnet.private_one.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "mongo_db_from_private_two" {
  security_group_id = aws_security_group.mongo_vm.id
  description       = "MongoDB from EKS private subnet two"
  ip_protocol       = "tcp"
  from_port         = 27017
  to_port           = 27017
  cidr_ipv4         = data.aws_subnet.private_two.cidr_block
}

resource "aws_vpc_security_group_egress_rule" "mongo_all_outbound" {
  security_group_id = aws_security_group.mongo_vm.id
  description       = "All outbound (S3 backup uploads, OS package updates)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ALB SG: HTTP/HTTPS from internet
resource "aws_security_group" "alb" {
  name        = "${var.project}-alb"
  description = "Application Load Balancer: HTTP/HTTPS from internet"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  #checkov:skip=CKV_AWS_260:HTTP from 0.0.0.0/0 is required for a public-facing ALB serving the demo app
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from internet"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_all_outbound" {
  security_group_id = aws_security_group.alb.id
  description       = "All outbound to VPC (ALB target groups)"
  ip_protocol       = "-1"
  cidr_ipv4         = data.aws_vpc.main.cidr_block
}