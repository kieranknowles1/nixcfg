# TODO: Use these outputs in authelia
output "smtp_username" {
  value = module.mail.smtp_username
}

output "smtp_endpoint" {
  value = "email-smtp.${var.region}.amazonaws.com"
}

output "smtp_password" {
  sensitive = true
  value     = module.mail.smtp_password
}

output "certificate" {
  value = module.dns.certificate
}

output "certificate_private_key" {
  value     = module.dns.certificate_private_key
  sensitive = true
}
