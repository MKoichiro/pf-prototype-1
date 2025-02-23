# Links to official documentation:
# * Resource: aws_vpc_endpoint [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint]

data "aws_subnet" "this" {
  id = var.private_subnet_ids[0]
}

locals {
  vpc_id = data.aws_subnet.this.vpc_id
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.interface_endpoints

  vpc_id              = local.vpc_id
  subnet_ids          = var.private_subnet_ids
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  security_group_ids  = var.vpcep-sg-ids
  private_dns_enabled = true
  tags = {
    Name = "${var.env_prefix}-pf-vpcep-${each.key}"
  }
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = var.gateway_endpoints

  vpc_id          = local.vpc_id
  service_name    = each.value
  route_table_ids = var.route_table_ids
  tags = {
    Name = "${var.env_prefix}-pf-vpcep-${each.key}"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count = (
    var.ssmmessages_endpoint != null
    ? 1
    : 0
  )

  vpc_id              = local.vpc_id
  subnet_ids          = var.private_subnet_ids
  service_name        = var.ssmmessages_endpoint
  vpc_endpoint_type   = "Interface"
  security_group_ids  = var.vpcep-sg-ids
  private_dns_enabled = true
  tags = {
    Name = "${var.env_prefix}-pf-vpcep-ssmmessages"
  }
}
