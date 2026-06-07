output "mongo_vm_role_arn"             { value = aws_iam_role.mongo_vm.arn }
output "mongo_vm_instance_profile_arn" { value = aws_iam_instance_profile.mongo_vm.arn }
output "mongo_vm_instance_profile_name" { value = aws_iam_instance_profile.mongo_vm.name }
output "eks_cluster_role_arn"          { value = aws_iam_role.eks_cluster.arn }
output "eks_node_role_arn"             { value = aws_iam_role.eks_node.arn }
output "mongo_vm_role_name" { value = aws_iam_role.mongo_vm.name }