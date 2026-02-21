variable "region" {
  type = string
  # Stockholm
  default = "eu-north-1"
}

variable "cloudflare_api_token" {
  type        = string
  description = <<EOF
    API token with the following permissions:
    - Zone.DNS Edit
    - Zone.SSL and Certificates Edit
  EOF
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Zone ID of the domain name"
  sensitive   = true
}

variable "ipv4" {
  type = string
}

variable "domain" {
  type    = string
  default = "selwonk.uk"
}

variable "unproxied_subdomains" {
  type        = list(string)
  description = "Subdomains to not proxy through CloudFlare, must match NixOS server module configurations"
  default     = ["photos"]
}

variable "project" {
  type    = string
  default = "selwonk"
}

variable "alert_email" {
  type = string
}
