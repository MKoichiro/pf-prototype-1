variable "env_prefix" {
  type        = string
  default     = "dev"
  description = "Environment prefix for resource names (e.g. dev-, stg-, prod-)"
}

variable "alb_dns_name" {
  type        = string
  description = ""
}

variable "alb_zone_id" {
  type        = string
  description = ""
}

variable "records" {
  type        = map(string)
  description = "Specify pairs of identifiers and domains as keys and values of the map"
}
