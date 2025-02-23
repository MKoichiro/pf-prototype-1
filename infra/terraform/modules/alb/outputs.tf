output "bastion_tg_arn" {
  value = aws_lb_target_group.bastion.arn
}

output "api_tg_arn" {
  value = aws_lb_target_group.api.arn
}

output "web_tg_arn" {
  value = aws_lb_target_group.web.arn
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

output "zone_id" {
  value = aws_lb.this.zone_id
}
