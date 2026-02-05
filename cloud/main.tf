terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }

    cloudflare = {
      source = "hashicorp/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Stockholm
  region = var.region

  default_tags {
    tags = {
      Environment = "production"
      Project = var.project
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# TODO: Manage DNS DKIM records
module "dns" {
  source = "./dns"

  zone_id = var.cloudflare_zone_id
  domain = var.domain
  ipv4 = var.ipv4
  project = var.project
}

# TODO: Manage videos used by portfolio (cloudflare R2)

module "budget" {
  source = "./budget"

  alert_email = var.alert_email
  project = var.project
}

module "mail" {
  source = "./mail"

  domain = var.domain
  region = var.region
}
