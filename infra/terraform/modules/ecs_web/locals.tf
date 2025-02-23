data "aws_ecr_repository" "web" {
  name = var.web_repo_name
}

locals {
  container_name = "${var.env_prefix}-pf-web-container"
  container_port = 80
  port_name      = "${var.env_prefix}-pf-web-container-80-tcp"
}

locals {
  web_td = [
    {
      name  = local.container_name
      image = "${data.aws_ecr_repository.web.repository_url}:${var.web_repo_tag}"
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
      secrets          = []
      ulimits          = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/pf-web-td"
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
