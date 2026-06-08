output "mongo_vm_id"        { value = aws_instance.mongo.id }
output "mongo_vm_public_ip" { value = aws_instance.mongo.public_ip }
output "backups_bucket"     { value = aws_s3_bucket.backups.id }
output "backups_bucket_url" { value = "https://${aws_s3_bucket.backups.id}.s3.${data.aws_region.current.region}.amazonaws.com/" }
output "secret_name"        { value = aws_secretsmanager_secret.mongo_credentials.name }
output "mongo_vm_private_ip" { value = aws_instance.mongo.private_ip }