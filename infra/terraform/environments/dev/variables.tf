variable "apply_immediately" {
  type        = bool
  default     = true
  description = "[true/false] Whether to apply RDS changes without waiting for the maintenance window"
}

variable "enable_bastion" {
  type        = bool
  default     = false
  description = "[true/false] Whether to create bastion ec2 instance"
}

variable "enable_ecs_exec" {
  type = bool
  description = "[true/false] Whether to use ecs exec command. This toggle ssmmessages vpc endpoint is presence or absence."
}

variable "enable_nat" {
  type = bool
  description = "[true/false] Whether to use nat gateway instead of vpc endpoints"
}

variable "use_latest_image" {
  description = "If true, use the latest commit hash from the remote repository as the image tag."
  type        = bool
}

# from terraform.tfvars
variable "git_user_name" {
  type = string
}

variable "remote_repository_name" {
  type = string
}
