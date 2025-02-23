variable "env_prefix" {
  type        = string
  default     = "dev"
  description = "Environment prefix for resource names (e.g. dev-, stg-, prod-)"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet to launch the EC2 instance into"
}

variable "ec2_sg_ids" {
  type        = list(string)
  description = "A list of security group ids for EC2"
}

variable "alb_bastion_tg_arn" {
  type        = string
  description = "Target Group ARN"
}
