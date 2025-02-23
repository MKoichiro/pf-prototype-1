variable "env_prefix" {
  type        = string
  default     = "dev"
  description = "Environment prefix for resource names (e.g. dev-, stg-, prod-)"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to arrange the ALB into"
}

variable "alb_sg_ids" {
  type        = list(string)
  description = "A list of security group ids for ALB"
}

variable "base_domain" {
  type        = string
  description = "Own domain"
}

variable "ssl_policy" {
  type        = string
  description = "'ELBSecurityPolicy-TLS13-1-2-2021-06' for example"
}

variable "log_bucket_name" {
  type        = string
  description = "The name of existing s3 bucket for access/connection logs"
}
