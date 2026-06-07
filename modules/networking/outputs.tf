output "vpc_id"             { value = data.aws_vpc.main.id }
output "vpc_cidr"           { value = data.aws_vpc.main.cidr_block }
output "public_subnet_ids"  { value = [data.aws_subnet.public_one.id, data.aws_subnet.public_two.id] }
output "private_subnet_ids" { value = [data.aws_subnet.private_one.id, data.aws_subnet.private_two.id] }
output "mongo_vm_sg_id"     { value = aws_security_group.mongo_vm.id }
output "alb_sg_id"          { value = aws_security_group.alb.id }