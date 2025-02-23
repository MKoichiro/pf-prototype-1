output "url" {
  value = "https://${local.own_domain}"
}

output "url_api_test" {
  value = "https://api.test.${local.own_domain}:8443/api/v1/users"
}

output "url_alb_dns" {
  value = "https://${module.alb.dns_name}"
}
