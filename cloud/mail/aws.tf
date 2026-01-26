variable "domain" {
  type = string
}

variable "region" {
  type = string
}

output "dkim_records" {
  value = aws_ses_domain_dkim.ses.dkim_tokens
}

output "smtp_username" {
  value = aws_iam_access_key.ses_auth.id
}

output "smtp_endpoint" {
  value = "email-smtp.${var.region}.amazonaws.com"
}

output "smtp_password" {
  sensitive = true
  value = aws_iam_access_key.ses_auth.ses_smtp_password_v4
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

resource "aws_iam_user" "ses_auth" {
  name = "selwonk-auth-iac"
}

data "aws_iam_policy_document" "ses_auth" {
  statement {
    effect = "Allow"
    actions = ["ses:SendRawEmail"]
    resources = [aws_ses_email_identity.ses_auth.arn]
  }
}

resource "aws_iam_policy" "ses_auth" {
  name = "selwonk_auth_send_email"
  policy = data.aws_iam_policy_document.ses_auth.json
}

resource "aws_iam_policy_attachment" "ses_auth" {
  name = "selwonk_auth_send_email_attachment"
  policy_arn = aws_iam_policy.ses_auth.arn
  users = [aws_iam_user.ses_auth.name]
}

resource "aws_iam_access_key" "ses_auth" {
  user = aws_iam_user.ses_auth.name
}
