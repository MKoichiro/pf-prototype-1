variable "env_prefix" {
  type        = string
  default     = "dev"
  description = "Environment prefix for resource names (e.g. dev-, stg-, prod-)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  type        = map(string)
  description = "Map of public subnet CIDR blocks"
}

variable "private_subnets" {
  type        = map(string)
  description = "Map of private subnet CIDR blocks"
}

variable "nat_location" {
  type = string
  description = "AZ where nat gateway allocate"
}
