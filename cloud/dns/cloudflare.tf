variable "zone_id" {
  type      = string
  sensitive = true
}

variable "project" {
  type = string
}

variable "domain" {
  type = string
}

# TODO: Support IPv6
variable "ipv4" {
  type = string
}

variable "dkim_records" {
  type = list(string)
}

variable "dkim_suffix" {
  type = string
}

output "certificate" {
  value = cloudflare_origin_ca_certificate.origin_ca.certificate
}

output "certificate_private_key" {
  value     = tls_private_key.private_key.private_key_pem
  sensitive = true
}

resource "cloudflare_dns_record" "dns" {
  for_each = toset([var.domain, "*"])
  zone_id  = var.zone_id
  name     = each.key
  content  = var.ipv4
  ttl      = 1 # Automatic
  proxied  = true
  type     = "A"
  comment  = "Primary DNS"
}

resource "cloudflare_dns_record" "dkim" {
  for_each = toset(var.dkim_records)
  zone_id  = var.zone_id
  name     = "${each.key}._domainkey"
  content  = "${each.key}.${var.dkim_suffix}"
  ttl      = 1 # Automatic
  type     = "CNAME"
  comment  = "AWS DKIM"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "csr" {
  private_key_pem = tls_private_key.private_key.private_key_pem
}

resource "time_rotating" "cert_rotate" {
  rotation_days = 330
}

resource "cloudflare_origin_ca_certificate" "origin_ca" {
  csr          = tls_cert_request.csr.cert_request_pem
  hostnames    = ["*.${var.domain}", var.domain]
  request_type = "origin-rsa"
  # TODO: Automate renewal and bring this down as low as possible
  requested_validity = 365

  lifecycle {
    replace_triggered_by = [time_rotating.cert_rotate.id]
  }
}
