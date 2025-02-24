# Links to official documentation:
# * Resource: aws_ecs_task_definition [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition]
# * Resource: aws_ecs_service         [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service]

data "aws_secretsmanager_secret" "rails_master_key" {
  name = var.rails_master_key
}

# Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.env_prefix}-pf-api-td"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode(local.api_td)
}

# Service
resource "aws_ecs_service" "this" {
  name                   = "${var.env_prefix}-pf-api-srv"
  cluster                = var.cluster_arn
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  platform_version       = "1.4.0" # equivalent to "latest" @2025/02/22
  enable_execute_command = true

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.api_sg_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_api_tg_arn
    container_name   = local.container_name
    container_port   = local.container_port
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.namespace_arn

    # ref: https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/APIReference/API_LogConfiguration.html
    log_configuration {
      log_driver = "awslogs"
      options = {
        awslogs-group         = "ecs/server"
        awslogs-region        = var.region_name
        awslogs-stream-prefix = "ecs-proxy"
        awslogs-create-group  = true
      }
    }

    service {
      port_name      = local.port_name
      discovery_name = "api-container"
      client_alias {
        port     = local.container_port
        dns_name = "api-container"
      }
    }
  }
}
