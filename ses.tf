data "aws_route53_zone" "primary" {
  name         = var.primary_domain
  private_zone = false
}

# TODO use deployment flags
# TODO Move to static-repo
resource "aws_ses_domain_identity" "ses_domain" {
  domain = lookup(var.email_from_domain, var.env_code)
}

resource "aws_ses_domain_mail_from" "ses_from" {
  domain           = aws_ses_domain_identity.ses_domain.domain
  mail_from_domain = "mail.${lookup(var.email_from_domain, var.env_code)}"
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "_amazonses.${lookup(var.email_from_domain, var.env_code)}"
  type    = "TXT"
  ttl     = "600"
  records = [join("", aws_ses_domain_identity.ses_domain.*.verification_token)]
}

# DKIM
resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = join("", aws_ses_domain_identity.ses_domain.*.domain)
}

resource "aws_route53_record" "ses_dkim_record" {
  count   = 3
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}._domainkey.${lookup(var.email_from_domain, var.env_code)}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# SPF
resource "aws_route53_record" "spf_mail_from" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = aws_ses_domain_mail_from.ses_from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "spf_domain" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = lookup(var.email_from_domain, var.env_code)
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "mx_mail_from" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = aws_ses_domain_mail_from.ses_from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${lookup(var.aws_region, var.env_code)}.amazonses.com"]
}
