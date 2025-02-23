# Links to official documentation:
# * Resource: aws_lb               [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb]
# * Resource: aws_lb_listener      [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener]
# * Resource: aws_lb_target_group  [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group]
# * Resource: aws_s3_bucket_policy [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy]

data "aws_subnet" "selected" {
  id = var.public_subnet_ids[0]
}

data "aws_acm_certificate" "clino_mania" {
  domain      = var.base_domain # Just specify the base domain name, even though multi-domain/wildcard certificates.
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_elb_service_account" "this" {}

data "aws_caller_identity" "this" {}

locals {
  vpc_id                    = data.aws_subnet.selected.vpc_id
  certificate_arn           = data.aws_acm_certificate.clino_mania.arn
  access_logging_prefix     = "${var.env_prefix}/access_logs"
  connection_logging_prefix = "${var.env_prefix}/connection_logs"
}


resource "aws_lb" "this" {
  name               = "${var.env_prefix}-pf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_sg_ids
  subnets            = var.public_subnet_ids

  access_logs {
    bucket  = var.log_bucket_name
    enabled = true
    prefix  = local.access_logging_prefix
  }

  connection_logs {
    bucket  = var.log_bucket_name
    enabled = true
    prefix  = local.connection_logging_prefix
  }
}

# Listeners & Rules
# HTTP:81
resource "aws_lb_listener" "http_81" {
  load_balancer_arn = aws_lb.this.arn
  port              = "81"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion.arn
  }
}

# HTTP:80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS:443
resource "aws_lb_listener" "https_443" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = local.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# HTTPS:8443
resource "aws_lb_listener" "https_8443" {
  load_balancer_arn = aws_lb.this.arn
  port              = "8443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = local.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_listener_rule" "https_8443" {
  listener_arn = aws_lb_listener.https_8443.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    host_header {
      values = ["api.test.${var.base_domain}"]
    }
  }
}


# Target groups
# bastion EC2
resource "aws_lb_target_group" "bastion" {
  name     = "${var.env_prefix}-pf-bastion-tg"
  port     = 81
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = 200
  }
}

# API
resource "aws_lb_target_group" "api" {
  name        = "${var.env_prefix}-pf-api-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = 200
  }
}

# WEB
resource "aws_lb_target_group" "web" {
  name        = "${var.env_prefix}-pf-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = 200
  }
}


# S3 bucket policy
# ref: https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/enable-access-logging.html
# ref: https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/enable-connection-logging.html
data "aws_s3_bucket" "logs" {
  bucket = var.log_bucket_name
}

resource "aws_s3_bucket_policy" "alb" {
  bucket = data.aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs.json
}

data "aws_iam_policy_document" "logs" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this.id]
    }
    actions = ["s3:PutObject"]
    resources = [
      "${data.aws_s3_bucket.logs.arn}/${local.access_logging_prefix}/AWSLogs/${data.aws_caller_identity.this.account_id}/*",
      "${data.aws_s3_bucket.logs.arn}/${local.connection_logging_prefix}/AWSLogs/${data.aws_caller_identity.this.account_id}/*"
    ]
  }
}
