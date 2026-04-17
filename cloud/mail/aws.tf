variable "domain" {
  type = string
}

variable "region" {
  type = string
}

output "dkim_records" {
  value = aws_ses_domain_dkim.ses.dkim_tokens
}

output "dkim_suffix" {
  value = "dkim.amazonses.com"
}

output "smtp_username" {
  value = aws_iam_access_key.ses.id
}

output "smtp_endpoint" {
  value = "email-smtp.${var.region}.amazonaws.com"
}

output "smtp_password" {
  sensitive = true
  value     = aws_iam_access_key.ses.ses_smtp_password_v4
}

resource "aws_ses_domain_identity" "ses" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "ses" {
  domain = aws_ses_domain_identity.ses.domain
}

resource "aws_iam_user" "ses" {
  name = "selwonk-smtp"
}

resource "aws_ses_configuration_set" "ses" {
  name = "selwonk-smtp-config-set"

  delivery_options {
    tls_policy = "Require"
  }
}

data "aws_iam_policy_document" "ses" {
  statement {
    effect    = "Allow"
    actions   = ["ses:SendRawEmail"]
    resources = [aws_ses_domain_identity.ses.arn, aws_ses_configuration_set.ses.arn]
  }
}

resource "aws_iam_policy" "ses" {
  name   = "selwonk_ses_send_email"
  policy = data.aws_iam_policy_document.ses.json
}


resource "aws_iam_policy_attachment" "ses" {
  name       = "selwonk_ses_send_email_attachment"
  policy_arn = aws_iam_policy.ses.arn
  users      = [aws_iam_user.ses.name]
}

resource "aws_iam_access_key" "ses" {
  user = aws_iam_user.ses.name
}
