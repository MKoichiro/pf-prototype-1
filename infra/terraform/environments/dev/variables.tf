# prompt on `terraform apply`
variable "apply_immediately" {
  type        = bool
  default     = true
  description = <<-EOF
    [true/false]
    Whether to apply RDS changes without waiting for the maintenance window.
  EOF
}

variable "enable_bastion" {
  type        = bool
  default     = false
  description = <<-EOF
    [true/false]
    Whether to create bastion ec2 instance.
  EOF
}

variable "enable_nat" {
  type        = bool
  description = <<-EOF
    [true/false]
    Whether to use nat gateway instead of vpc endpoints.
  EOF
}

variable "enable_ecs_exec" {
  type        = bool
  description = <<-EOF
    [true/false]
    Whether to use the ecs exec command.
    This toggles whether the vpc endpoint for ssmmessages is present or absent.
    If enable_nat is true, this value is ignored and no vpc endpoints are created.
  EOF
}

variable "use_latest_image" {
  type        = bool
  description = <<-EOF
    [true/false]
    If true, use the latest commit hash from the remote repository as the image tag.
  EOF
}

# from terraform.tfvars
variable "git_user_name" {
  type = string
}

variable "remote_repository_name" {
  type = string
}
