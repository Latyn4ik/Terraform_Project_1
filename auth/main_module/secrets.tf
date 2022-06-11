resource "aws_secretsmanager_secret" "auth_verification" {
  description = "Auth verification main secret for Lambda"
  name        = var.auth_verification_lambda_secret_name
}

resource "aws_secretsmanager_secret_version" "main_verification" {
  secret_id     = aws_secretsmanager_secret.auth_verification.id
  secret_string = var.auth_verification_lambda_secret_value
}

resource "aws_secretsmanager_secret" "auth_license" {
  description = "Auth license main secret for Lambda"
  name        = var.auth_license_lambda_secret_name
}

resource "aws_secretsmanager_secret_version" "main_license" {
  secret_id     = aws_secretsmanager_secret.auth_license.id
  secret_string = var.auth_license_lambda_secret_value
}
