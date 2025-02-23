# Links to official documentation:
# * Resource: aws_ssm_parameter [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter]

resource "aws_ssm_parameter" "secrets" {
  for_each    = var.parameters
  name        = "/${var.env_prefix}/api/${each.key}"
  description = each.value.description
  type        = "SecureString"
  value       = each.value.value
}
