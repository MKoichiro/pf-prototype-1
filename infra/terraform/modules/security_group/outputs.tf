output "alb_sg_id" {
  value = aws_security_group.this["alb"].id
}

output "rds_sg_id" {
  value = aws_security_group.this["rds"].id
}

output "api_sg_id" {
  value = aws_security_group.this["api"].id
}

output "web_sg_id" {
  value = aws_security_group.this["web"].id
}

output "vpcep_sg_id" {
  value = aws_security_group.this["vpcep"].id
}

output "ec2_sg_id" {
  value = aws_security_group.this["ec2"].id
}
