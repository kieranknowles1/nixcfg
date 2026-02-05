variable "zone_id" {
  type = string
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

resource "cloudflare_dns_record" "dns" {
  for_each = toset([var.domain, "*"])
  zone_id = var.zone_id
  name = each.key
  content = var.ipv4
  ttl = 1 # Automatic
  proxied = true
  type = "A"
  comment = "Primary DNS"
}

resource "cloudflare_dns_record" "dkim" {
  for_each = toset(var.dkim_records)
  zone_id = var.zone_id
  name = "${each.key}._domainkey"
  content = "${each.key}.${var.dkim_suffix}"
  ttl = 1 # Automatic
  type = "CNAME"
  comment = "AWS DKIM"
}
