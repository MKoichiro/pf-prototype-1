data "aws_ecr_repository" "api" {
  name = var.api_repo_name
}

locals {
  container_name = "${var.env_prefix}-pf-api-container"
  container_port = 8080
  port_name      = "${var.env_prefix}-pf-api-container-8080-tcp"
}

locals {
  api_td = [
    {
      name  = local.container_name
      image = "${data.aws_ecr_repository.api.repository_url}:${var.api_repo_tag}"
      cpu   = 0
      portMappings = [
        {
          name          = local.port_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      essential        = true
      environment      = []
      environmentFiles = []
      mountPoints      = []
      volumesFrom      = []
      secrets = [
        {
          name = "PROD_DB_USER"
          # https://docs.aws.amazon.com/ja_jp/batch/latest/userguide/specifying-sensitive-data-secrets.html#secrets-envvar
          valueFrom = "${var.secrets_arn}:username::"
        },
        {
          name      = "PROD_DB_PASSWORD"
          valueFrom = "${var.secrets_arn}:password::"
        },
        {
          name      = "PROD_DB_HOST"
          valueFrom = "/${var.env_prefix}/api/db_host"
        },
        {
          name      = "PROD_DB_PORT"
          valueFrom = "/${var.env_prefix}/api/db_port"
        },
        {
          name      = "PROD_DB_NAME"
          valueFrom = "/${var.env_prefix}/api/db_name"
        },
        {
          name      = "RAILS_MASTER_KEY"
          valueFrom = "${data.aws_secretsmanager_secret.rails_master_key.arn}:rails_master_key::"
        }
      ]
      ulimits = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/pf-api-td"
          mode                  = "non-blocking"
          awslogs-create-group  = "true"
          max-buffer-size       = "25m"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
        secretOptions = []
      }
      systemControls = []
    }
  ]
}
