data "aws_region" "current" {}

data "external" "latest_commit" {
  program = ["bash", "${path.module}/sha_getter.sh"]

  query = {
    repo_url = "git@github.com:${var.git_user_name}/${var.remote_repository_name}.git"
    branch   = "main"
  }
}

locals {
  env        = "dev"
  vpc_cidr   = "10.1.0.0/16"
  own_domain = "clino-mania.net"
}

module "vpc" {
  source       = "../../modules/vpc"
  env_prefix   = local.env
  nat_location = var.enable_nat ? "ap-northeast-1a" : null

  vpc_cidr = local.vpc_cidr
  public_subnets = {
    "ap-northeast-1a" = "10.1.0.0/24"
    "ap-northeast-1c" = "10.1.1.0/24"
    "ap-northeast-1d" = "10.1.2.0/24"
  }
  private_subnets = {
    "ap-northeast-1a" = "10.1.100.0/24"
    "ap-northeast-1c" = "10.1.101.0/24"
    "ap-northeast-1d" = "10.1.102.0/24"
  }
}

module "security_group" {
  source     = "../../modules/security_group"
  env_prefix = local.env
  vpc        = module.vpc.vpc
}

module "vpc_ep" {
  count = var.enable_nat ? 0 : 1

  source             = "../../modules/vpc_ep"
  env_prefix         = local.env
  vpc_cidr           = local.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids
  route_table_ids    = module.vpc.private_route_table_ids
  vpcep-sg-ids       = [module.security_group.vpcep_sg_id]

  gateway_endpoints = {
    "s3" = "com.amazonaws.${data.aws_region.current.name}.s3"
  }

  interface_endpoints = {
    "ecr_api"         = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
    "ecr_dkr"         = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
    "logs"            = "com.amazonaws.${data.aws_region.current.name}.logs"
    "ssm"             = "com.amazonaws.${data.aws_region.current.name}.ssm"
    "secrets_manager" = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  }

  ssmmessages_endpoint = (
    var.enable_ecs_exec
    ? "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
    : null
  )
}

module "alb" {
  source            = "../../modules/alb"
  env_prefix        = local.env
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_ids        = [module.security_group.alb_sg_id]
  base_domain       = local.own_domain
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  log_bucket_name   = "pf-alb-logs-2025-02-22"
}

# Fill in the entries in the db_config_* block, referring to the following documentation
# Terraform > Resource: aws_db_instance     [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance]
# AWS RDS API reference > CreateDBInstance  [https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html]
#
# * To decide "engine_version", you can check out the available engine versions by running the following command.
#   `$ aws rds describe-db-engine-versions --default-only --engine postgres`
# * To check out other internal preferences, See ../../modules/rds/main.tf
module "rds" {
  source            = "../../modules/rds"
  env_prefix        = local.env
  rds_sg_ids        = [module.security_group.rds_sg_id]
  apply_immediately = var.apply_immediately
  subnet_ids        = module.vpc.private_subnet_ids

  db_config_basics = {
    # password is managed by AWS Secrets Manager automatically
    identifier        = "test"
    username          = "test"
    db_name           = "test"
    allocated_storage = 20
    # max_allocated_storage = 50 # if not set, it means auto-scaling is disabled
    storage_type   = "gp3"
    engine         = "postgres"
    engine_version = "16.3"
    instance_class = "db.t3.micro"
    port           = 5432
    network_type   = "IPV4" # or "DUAL" are valid
  }

  db_config_details = {
    multi_az                   = false
    auto_minor_version_upgrade = true
    backup_retention_period    = 0 # [day], 0 means disable backup
    skip_final_snapshot        = true
    deletion_protection        = false
    delete_automated_backups   = true
    publicly_accessible        = false
    # See, "EnableCloudwatchLogsExports.member.N"
    # in [https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html#API_CreateDBInstance_RequestParameters]
    enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  }
}

module "ecs_common" {
  source     = "../../modules/ecs_common"
  env_prefix = local.env
  vpc_id     = module.vpc.vpc.id
}

module "ecs_api" {
  source                      = "../../modules/ecs_api"
  depends_on                  = [module.rds] # rds -> api_srv -> web_srv
  env_prefix                  = local.env
  region_name                 = data.aws_region.current.name
  subnet_ids                  = module.vpc.private_subnet_ids
  cluster_arn                 = module.ecs_common.cluster_arn
  namespace_arn               = module.ecs_common.namespace_arn
  ecs_task_execution_role_arn = module.ecs_common.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.ecs_common.ecs_task_role_arn

  alb_api_tg_arn = module.alb.api_tg_arn
  api_repo_name  = "pf-api-repo"
  api_repo_tag = (
    var.use_latest_image
    ? data.external.latest_commit.result.commit_hash
    : "216e5852bd7838efc5575e0b5b51d4304faf0d52"
  )
  api_sg_ids = [module.security_group.api_sg_id]

  secrets_arn      = module.rds.secrets_arn
  rails_master_key = "rails_master_key"
}

module "ecs_web" {
  source                      = "../../modules/ecs_web"
  depends_on                  = [module.ecs_api] # rds -> api_srv -> web_srv, mandatory for service connect to be worked fine
  env_prefix                  = local.env
  region_name                 = data.aws_region.current.name
  subnet_ids                  = module.vpc.private_subnet_ids
  cluster_arn                 = module.ecs_common.cluster_arn
  namespace_arn               = module.ecs_common.namespace_arn
  ecs_task_execution_role_arn = module.ecs_common.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.ecs_common.ecs_task_role_arn

  alb_web_tg_arn = module.alb.web_tg_arn
  web_repo_name  = "pf-web-repo"
  web_repo_tag = (
    var.use_latest_image
    ? data.external.latest_commit.result.commit_hash
    : "216e5852bd7838efc5575e0b5b51d4304faf0d52"
  )
  web_sg_ids = [module.security_group.web_sg_id]
}

module "parameter_store" {
  source     = "../../modules/parameter_store"
  env_prefix = local.env
  parameters = {
    db_host = {
      value       = module.rds.db_host
      description = "The parameter description a"
    },
    db_name = {
      value       = "test"
      description = "The parameter description b"
    },
    db_port = {
      value       = "5432"
      description = "The parameter description c"
    }
  }
}

module "dns_records" {
  source       = "../../modules/dns_records"
  env_prefix   = local.env
  alb_dns_name = module.alb.dns_name
  alb_zone_id  = module.alb.zone_id
  records = {
    "root"     = local.own_domain
    "api_test" = "api.test.${local.own_domain}"
  }
}

# bastion server for versatile use
module "ec2" {
  count = var.enable_bastion ? 1 : 0

  source             = "../../modules/ec2"
  env_prefix         = local.env
  subnet_id          = module.vpc.public_subnet_ids[0]
  ec2_sg_ids         = [module.security_group.ec2_sg_id]
  alb_bastion_tg_arn = module.alb.bastion_tg_arn
}
