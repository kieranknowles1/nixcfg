variable "domain" {
  type = string
}

output "dkim_records" {
  value = aws_ses_domain_dkim.ses.dkim_tokens
}

resource "aws_ses_domain_identity" "ses" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "ses" {
  domain = aws_ses_domain_identity.ses.domain
}

resource "aws_ses_email_identity" "ses_auth" {
  email = "auth@${var.domain}"
}
