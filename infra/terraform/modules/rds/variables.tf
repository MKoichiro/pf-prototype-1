variable "env_prefix" {
  type        = string
  default     = "dev"
  description = "Environment prefix for resource names (e.g. dev-, stg-, prod-)"
}

variable "rds_sg_ids" {
  type        = list(string)
  description = "A list of security group ids for RDS"
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Apply changes without waiting for the maintenance window"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A List of private subnet IDs"
}

variable "db_config_basics" {
  type = object({
    identifier        = string
    username          = string
    db_name           = string
    allocated_storage = number
    # max_allocated_storage = number
    storage_type   = string
    engine         = string
    engine_version = string
    instance_class = string
    port           = number
    network_type   = string
  })

  description = "DB configuration"
}

variable "db_config_details" {
  type = object({
    multi_az                        = bool
    auto_minor_version_upgrade      = bool
    backup_retention_period         = number
    skip_final_snapshot             = bool
    publicly_accessible             = bool
    enabled_cloudwatch_logs_exports = list(string)
  })

  description = "DB configuration details"
}
