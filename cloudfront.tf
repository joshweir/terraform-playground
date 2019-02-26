locals {
  api_origin_id = "apiOrigin"
  api_without_stage_origin_id = "apiWithoutStageOrigin"
}

resource "aws_cloudfront_distribution" "joshs_distribution" {
  
  origin {
    domain_name = "${local.api_gw_hostname}"
    origin_id   = "${local.api_origin_id}"

    custom_origin_config  {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  # example origin where the /v1 path is auto appended to the endpoint origin domain so that 
  # enforced vendor required routes like /apple-app-site-association can still be routed to api gw endpoint that 
  # must include the stage path /v1 will automatically route to /v1/apple-app-site-association
  origin {
    domain_name = "${local.api_gw_hostname}"
    origin_id   = "${local.api_without_stage_origin_id}"
    origin_path = "/v1"

    custom_origin_config  {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  # example for communicate the default cache behaviour is to hit the s3 bucket that has our web app
  # default_cache_behavior {
  #   allowed_methods  = ["GET", "HEAD"]
  #   cached_methods   = ["GET", "HEAD"]
  #   target_origin_id = "${local.web_build_s3_origin_id}"

  #   forwarded_values {
  #     query_string = false

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   viewer_protocol_policy = "redirect-to-https"
  #   min_ttl                = 0
  #   default_ttl            = 1
  #   max_ttl                = 1
  # }

  default_cache_behavior {
    # optionally include a path pattern for each cache behviour, the default shouldnt have one really
    #path_pattern     = "/v1/public/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.api_origin_id}"

    forwarded_values {
      query_string = false
      headers = ["Authorization", "User-Agent"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 1
    max_ttl                = 1
  }

  ordered_cache_behavior {
    path_pattern     = "/apple-app-site-association"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.api_without_stage_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 1
    max_ttl                = 1
  }

  enabled             = true
  is_ipv6_enabled     = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # this is where we add our domain name 
  #aliases = ["joshweir.com","another-owned-joshweir.com"]
  default_root_object = "index.html"

  # if specifying aliases (my own dns) then need to provide the certificate associated
  # viewer_certificate {
  #   acm_certificate_arn = "${aws_acm_certificate.web_build_distribution_cert.arn}"
  #   ssl_support_method = "sni-only"
  # }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}