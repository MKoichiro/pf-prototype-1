variable "env_prefix" {
  type        = string
  default     = "dev"
  description = "Environment prefix for resource names (e.g. dev-, stg-, prod-)"
}

variable "region_name" {
  type        = string
  description = "current region name"
}

variable "subnet_ids" {
  type        = list(string)
  description = ""
}

variable "cluster_arn" {
  type        = string
  description = "ARN of the cluster"
}

variable "namespace_arn" {
  type        = string
  description = ""
}

variable "secrets_arn" {
  type = string
  # ephemeral = true
  description = ""
}

variable "alb_api_tg_arn" {
  type        = string
  description = ""
}

variable "api_sg_ids" {
  type        = list(string)
  description = "A list of security group ids for api task"
}

variable "rails_master_key" {
  type        = string
  description = "Register name of secrets manager for rails_master_key"
}

variable "api_repo_name" {
  type        = string
  description = "Repository name for api container"
}

variable "api_repo_tag" {
  type        = string
  description = "Image tag for api container"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "ARN of task execution role"
}

variable "ecs_task_role_arn" {
  type = string
  description = "ARN of task role"
}
