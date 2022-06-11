resource "aws_lambda_function" "authorizer" {
  function_name = var.lambda_authorizer_name
  filename      = "${path.module}/lambda_package/authorizer_lambda_package.zip"
  role          = var.lambda_role
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size
  environment {
    variables = {
      IP_WHITELIST = jsonencode(var.authorizer_ip_whitelist)
    }
  }
}

resource "aws_lambda_permission" "api_gateway_trigger" {
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.authorizer.function_name
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}
