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

variable "alb_web_tg_arn" {
  type        = string
  description = ""
}

variable "web_sg_ids" {
  type        = list(string)
  description = "A list of security group ids for web task"
}

variable "web_repo_name" {
  type        = string
  description = "Repository name for web container"
}

variable "web_repo_tag" {
  type        = string
  description = "Image tag for web container"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "ARN of task execution role"
}

variable "ecs_task_role_arn" {
  type = string
  description = "ARN of task role"
}
