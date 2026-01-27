variable "region" {
  type = string
  # Stockholm
  default = "eu-north-1"
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
