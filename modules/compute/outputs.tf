output "cluster_name"            { value = aws_eks_cluster.main.name }
output "cluster_endpoint"        { value = aws_eks_cluster.main.endpoint }
output "cluster_ca_certificate"  { value = aws_eks_cluster.main.certificate_authority[0].data }
output "cluster_oidc_issuer"     { value = aws_eks_cluster.main.identity[0].oidc[0].issuer }
output "cluster_oidc_provider"   { value = aws_iam_openid_connect_provider.cluster.arn }
output "node_group_name"         { value = aws_eks_node_group.main.node_group_name }