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

resource "cloudflare_dns_record" "main_dns" {
  zone_id = var.zone_id
  name = var.domain
  content = var.ipv4
  ttl = 1 # Automatic
  proxied = true
  type = "A"
  comment = "Primary DNS record"
}

resource "cloudflare_dns_record" "subdomain_dns" {
  zone_id = var.zone_id
  name = "*" # *.domain
  content = var.ipv4
  ttl = 1 # Automatic
  proxied = true
  type = "A"
  comment = "Wildcard DNS record"
}
