# Links to official documentation:
# * Resource: aws_instance                          [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance]
# * Resource: aws_subnet                            [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet]

resource "aws_db_instance" "this" {
  apply_immediately = var.apply_immediately

  # db_config_basics
  identifier        = var.db_config_basics.identifier
  username          = var.db_config_basics.username
  db_name           = var.db_config_basics.db_name
  allocated_storage = var.db_config_basics.allocated_storage
  # max_allocated_storage = var.db_config_basics.max_allocated_storage
  storage_type   = var.db_config_basics.storage_type
  engine         = var.db_config_basics.engine
  engine_version = var.db_config_basics.engine_version
  instance_class = var.db_config_basics.instance_class
  port           = var.db_config_basics.port
  network_type   = var.db_config_basics.network_type

  # db_config_details
  multi_az                        = var.db_config_details.multi_az
  auto_minor_version_upgrade      = var.db_config_details.auto_minor_version_upgrade
  backup_retention_period         = var.db_config_details.backup_retention_period
  skip_final_snapshot             = var.db_config_details.skip_final_snapshot
  publicly_accessible             = var.db_config_details.publicly_accessible
  enabled_cloudwatch_logs_exports = var.db_config_details.enabled_cloudwatch_logs_exports

  # configs decided internally
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = var.rds_sg_ids
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.env_prefix}-pf-db-subnet-group"
  subnet_ids = var.subnet_ids
}
