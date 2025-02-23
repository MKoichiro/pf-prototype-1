variable "env_prefix" {
  type        = string
  default     = "dev"
  description = "Environment prefix for resource names (e.g. dev-, stg-, prod-)"
}

variable "parameters" {
  type = map(object({
    description = string,
    value       = string
  }))
  description = "A map of SSM parameters with description and value"
}
