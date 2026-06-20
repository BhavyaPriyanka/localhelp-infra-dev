resource "aws_ssm_parameter" "frontend_private_key" {
  name  = "/${var.project_name}/${var.environment}/frontend/private_key"
  type  = "SecureString"
  value = tls_private_key.frontend.private_key_pem
}



