locals {
  dvo = tolist(aws_acm_certificate.this.domain_validation_options)[0]
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-acm-cert"
  })
}

resource "aws_route53_record" "cert_validation" {
  zone_id         = var.hosted_zone_id
  name            = local.dvo.resource_record_name
  type            = local.dvo.resource_record_type
  records         = [local.dvo.resource_record_value]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}