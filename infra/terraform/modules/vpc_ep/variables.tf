variable "env_prefix" {
  type        = string
  description = "Environment prefix for resource names (e.g. dev-, stg-, prod-)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the VPC"
}

variable "route_table_ids" {
  type        = list(string)
  description = "Route table IDs for the VPC"
}

variable "gateway_endpoints" {
  type        = map(string)
  description = "Map of gateway endpoints"
}

variable "interface_endpoints" {
  type        = map(string)
  description = "Map of interface endpoints"
}

variable "vpcep-sg-ids" {
  type = list(string)
  description = "A list of security group ids for vpc endpoints"
}

variable "ssmmessages_endpoint" {
  type = string
  description = "The Endpoint name for ssmmessages"
}
