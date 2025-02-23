# Links to official documentation:
# * Resource: aws_route53_record [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record]

locals {
  zone_id    = data.aws_route53_zone.this.zone_id
  own_domain = var.records["root"]
}

data "aws_route53_zone" "this" {
  name         = "${local.own_domain}." # FQDN
  private_zone = false
}

resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = local.zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}
