variable "region" {
  type = string
  # Stockholm
  default = "eu-north-1"
}

variable "cloudflare_api_token" {
  type = string
  description = "API token with Zone.DNS Edit permission"
  sensitive = true
}

variable "cloudflare_zone_id" {
  type = string
  description = "Zone ID of the domain name"
  sensitive = true
}

variable "ipv4" {
  type = string
}

variable "domain" {
  type = string
  default = "selwonk.uk"
}

variable "project" {
  type = string
  default = "selwonk"
}

variable "alert_email" {
  type = string
}
