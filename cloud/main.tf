terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  # Stockholm
  region = var.region
}

# TODO: Manage DNS DKIM records
# module "dns" {
#   source = "./dns"

#   zone_id = "467510a64bd287bfa4a2870853ce70af"
#   dkim_records = module.mail.dkim_records
# }

# TODO: Manage videos used by portfolio (cloudflare R2)

module "mail" {
  source = "./mail"

  domain = "selwonk.uk"
  region = var.region
}

variable "default_tags" {
  type = map(string)
  default = {
    Name = "selwonk-hcl"
  }
}
