# Links to official documentation:
# * Resource: aws_vpc                     [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc]
# * Resource: aws_subnet                  [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet]
# * Resource: aws_route_table             [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table]
# * Resource: aws_route_table_association [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association]
# * Resource: aws_internet_gateway        [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway]

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env_prefix}-pf-vpc"
  }
}

# Public Subnets & Route Table
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.env_prefix}-pf-public-subnet-${split("-", each.key)[2]}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.env_prefix}-pf-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private Subnets & Route Table
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.env_prefix}-pf-private-subnet-${split("-", each.key)[2]}"
  }
}

# You need to explicitly create a route table to pass the route_table_id to the gateway type aws_vpc_endpoint resource for terraform management.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.nat_location != null ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.this[0].id
    }
  }

  tags = {
    Name = "${var.env_prefix}-pf-private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}



# Elastic IP
resource "aws_eip" "nat" {
  count = var.nat_location != null ? 1 : 0

  domain = "vpc"

  tags = {
    Name = "${var.env_prefix}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  count = var.nat_location != null ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public["${var.nat_location}"].id
  depends_on    = [aws_eip.nat]

  tags = {
    Name = "${var.env_prefix}-nat-gateway"
  }
}
