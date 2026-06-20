module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 4.0"

  aliases = ["cdn.example.com"]

  comment             = "Frontend CDN"
  enabled             = true
  default_root_object = "index.html"

  create_origin_access_control = true

  origin = {
    s3 = {
      domain_name = aws_s3_bucket.website.bucket_regional_domain_name
      origin_id   = "s3-origin"

      origin_access_control = "s3"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-CORS-S3Origin"
    response_headers_policy_name = "Managed-SimpleCORS"
  }

  viewer_certificate = {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}