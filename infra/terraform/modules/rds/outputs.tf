# There is no official corroboration that master_user_secret is an array, but actually it may be an array.
# [HashiCorp blog] https://www.hashicorp.com/ja/blog/terraform-1-10-improves-handling-secrets-in-state-with-ephemeral-values
# [Github issue] https://github.com/hashicorp/terraform-provider-aws/issues/31661#issuecomment-1858556452
output "secrets_arn" {
  value = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "db_host" {
  value = aws_db_instance.this.address
}
