terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.69.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "mgmt"
  region  = "us-east-1"
  default_tags {
    tags = var.default_tags
  }
#   assume_role {
#     # The role ARN within whatever AWS Account corresponds to the env/workspace (i.e. Target Account)
#     # Running terraform will authN into the mgmt Account then AssumeRole into the target account
#     role_arn = "arn:aws:iam::${var.aws_account_id}:role/terraform-cross-account-role"
#   }
}

resource "aws_s3_bucket" "website_bucket" {
    bucket = "blah99k99-59-74-55b-bankwaale-us"
    # acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website_bucket" {
    bucket = aws_s3_bucket.website_bucket.id

    index_document {
        suffix = "index.html"
    }
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}


resource "aws_acm_certificate" "cert" {
  domain_name       = "blah99k99.59.74.55b.bankwaale.us"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "blah99k99.59.74.55b.bankwaale.us"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = "Z0635064353VJMP3059YU"
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website_bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for blah99k99.59.74.55b.bankwaale.us"
  default_root_object = "index.html"

  aliases = ["blah99k99.59.74.55b.bankwaale.us"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website_bucket.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    response_headers_policy_id = aws_cloudfront_response_headers_policy.csp_policy.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_response_headers_policy" "csp_policy" {
  name = "CSPPolicy"

  security_headers_config {
    content_security_policy {
      override = true
      content_security_policy = "frame-ancestors 'self' https://app-speed-6220-dev-ed.scratch.lightning.force.com"
    }
  }
}


resource "aws_route53_record" "www" {
  zone_id = "Z0635064353VJMP3059YU"
  name    = "blah99k99.59.74.55b.bankwaale.us"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for blah99k99.59.74.55b.bankwaale.us"
}