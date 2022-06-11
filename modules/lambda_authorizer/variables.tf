variable "api_gateway_execution_arn" {
  description = "API Gateway execution ARN for Lambda permissions"
  type        = string
}

variable "lambda_authorizer_name" {
  description = "Name of Lambda Authorizer"
  type        = string
}

variable "authorizer_ip_whitelist" {
  description = "Name o Authorizer"
  type        = list(string)
}

variable "lambda_role" {
  description = "Role for the Lambda"
  type        = string
}

variable "lambda_handler" {
  description = "Lambda Handler"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Lambda Runtime"
  type        = string
  default     = "nodejs14.x"
}

variable "lambda_timeout" {
  description = "Lambda Timeout period in seconds"
  type        = number
  default     = 60
}

variable "lambda_memory_size" {
  description = "Lambda memory size"
  type        = number
  default     = 128
}