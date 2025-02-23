variable "env_prefix" {
  type        = string
  default     = "dev"
  description = "Environment prefix for resource names (e.g. dev-, stg-, prod-)"
}

variable "vpc_id" {
  type        = string
  description = ""
}
