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
  region = "eu-north-1"
}

# TODO: Manage DNS DKIM records
# module "dns" {
#   source = "./dns"

#   zone_id = "467510a64bd287bfa4a2870853ce70af"
#   dkim_records = module.mail.dkim_records
# }

module "mail" {
  source = "./mail"

  domain = "selwonk.uk"
}

variable "default_tags" {
  type = map(string)
  default = {
    Name = "selwonk-hcl"
  }
}
