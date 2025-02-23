# Links to official documentation:
# * Resource: aws_security_group                  [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group]
# * Resource: aws_vpc_security_group_egress_rule  [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule]
# * Resource: aws_vpc_security_group_ingress_rule [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule]

data "http" "my_ip" {
  url = "http://checkip.amazonaws.com/"
}

locals {
  target_resource_identifiers = {
    "rds"   = "rds",
    "alb"   = "alb",
    "api"   = "api",
    "web"   = "web",
    "ec2"   = "ec2",
    "vpcep" = "vpcep",
  }

  my_ip          = "${chomp(data.http.my_ip.response_body)}/32"
  vpc_cidr_block = var.vpc.cidr_block
  vpc_id         = var.vpc.id

  # list of security groups to attach egress rule that allows "All traffics" form "Anywhere"
  egress_all_allow = {
    "rds"   = aws_security_group.this["rds"].id,
    "alb"   = aws_security_group.this["alb"].id,
    "api"   = aws_security_group.this["api"].id,
    "web"   = aws_security_group.this["web"].id,
    "ec2"   = aws_security_group.this["ec2"].id,
    "vpcep" = aws_security_group.this["vpcep"].id,
  }

  # list of security groups to attach ingress rule that allows "All HTTP traffics" form "Anywhere"
  ingress_all_http_allow = {
    "alb" = aws_security_group.this["alb"].id,
  }

  # list of security groups to attach ingress rule that allows "SSH traffics" form "My IP"
  ingress_all_ssh_allow = {
    "ec2" = aws_security_group.this["ec2"].id,
  }
}

resource "aws_security_group" "this" {
  for_each = local.target_resource_identifiers

  name   = "${var.env_prefix}-pf-${each.value}-sg"
  vpc_id = local.vpc_id
}

# egress rules
resource "aws_vpc_security_group_egress_rule" "egress" {
  for_each = local.egress_all_allow

  security_group_id = each.value
  cidr_ipv4         = "0.0.0.0/0"
  # semantically equivalent to all ports;
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule#ip_protocol-1
  ip_protocol = "-1"
}


#  ingress rules
# [versatile] 1: ssh from my ip
resource "aws_vpc_security_group_ingress_rule" "ssh_my_ip" {
  for_each = local.ingress_all_ssh_allow

  security_group_id = each.value
  cidr_ipv4         = local.my_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# [versatile] 2: http from Anywhere
resource "aws_vpc_security_group_ingress_rule" "http_anywhere" {
  for_each = local.ingress_all_http_allow

  security_group_id = each.value
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# [alb] https from anywhere
resource "aws_vpc_security_group_ingress_rule" "https_from_anywhere" {
  security_group_id = aws_security_group.this["alb"].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# [alb] tcp:8443 from anywhere
resource "aws_vpc_security_group_ingress_rule" "tcp_8443_from_my_ip" {
  security_group_id = aws_security_group.this["alb"].id
  cidr_ipv4         = local.my_ip
  from_port         = 8443
  to_port           = 8443
  ip_protocol       = "tcp"
}

# [rds] postgresql:5432 from api
resource "aws_vpc_security_group_ingress_rule" "rds_postgresql_from_api" {
  security_group_id            = aws_security_group.this["rds"].id
  referenced_security_group_id = aws_security_group.this["api"].id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# [api] tcp:8080 from alb
resource "aws_vpc_security_group_ingress_rule" "api_tcp_8080_from_alb" {
  security_group_id            = aws_security_group.this["api"].id
  referenced_security_group_id = aws_security_group.this["alb"].id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# [api] tcp:8080 from web
resource "aws_vpc_security_group_ingress_rule" "api_tcp_8080_from_web" {
  security_group_id            = aws_security_group.this["api"].id
  referenced_security_group_id = aws_security_group.this["web"].id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# [web] http from alb
resource "aws_vpc_security_group_ingress_rule" "web_http_from_alb" {
  security_group_id            = aws_security_group.this["web"].id
  referenced_security_group_id = aws_security_group.this["alb"].id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# [ec2] http from alb
resource "aws_vpc_security_group_ingress_rule" "ec2_http_from_alb" {
  security_group_id            = aws_security_group.this["ec2"].id
  referenced_security_group_id = aws_security_group.this["alb"].id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# [vpcep] https from vpc
resource "aws_vpc_security_group_ingress_rule" "vpcep_https_from_vpc" {
  security_group_id = aws_security_group.this["vpcep"].id

  cidr_ipv4   = local.vpc_cidr_block
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}
