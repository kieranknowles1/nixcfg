terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    cloudflare = {
      source  = "hashicorp/cloudflare"
      version = "~> 5.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  # Stockholm
  region = var.region

  default_tags {
    tags = {
      Environment = "production"
      Project     = var.project
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "mail" {
  source = "./mail"

  domain = var.domain
  region = var.region
}

module "dns" {
  source = "./dns"

  zone_id      = var.cloudflare_zone_id
  domain       = var.domain
  ipv4         = var.ipv4
  project      = var.project
  dkim_records = module.mail.dkim_records
  dkim_suffix  = module.mail.dkim_suffix
}

# TODO: Manage videos used by portfolio (cloudflare R2)

module "budget" {
  source = "./budget"

  alert_email = var.alert_email
  project     = var.project
}
