output "state_bucket" { value = aws_s3_bucket.tf_state.id }
/* output "lock_table"   { value = aws_dynamodb_table.tf_lock.name } */
output "account_id" { value = data.aws_caller_identity.current.account_id }