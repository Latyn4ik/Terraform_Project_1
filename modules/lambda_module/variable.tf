variable "environment" {
  type        = string
  description = "Type of environment"
}

variable "lambda_role" {
  description = "Role for the Lambda"
  type        = string
}

variable "lambda_vpc_conf_security_group_ids" {
  description = "Security group IDs for the Lambda VPC configuration"
  type        = string
}

variable "lambda_vpc_conf_subnet_ids" {
  description = "Subnet IDs for the Lambda VPC configuration"
  type        = list(string)
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

variable "lambda_with_extra_memory" {
  description = "Lambda functions that needs more memory"
  type        = string
  default     = "validate_token"
}

variable "lambda_layers_list" {
  description = "List of Lambda functions"
  type        = list(string)
  default     = ["test_layer"]
}

variable "lambda_list_main" {
  description = "List of Lambda functions"
  type        = any
}

variable "lambda_environment_variables" {
  description = "A map that defines environment variables for the Lambda Function"
  type        = map(string)
  default     = {}
}

variable "lambda_on_fail_sns_topic" {
  description = "SNS topic for getting on_fail notifications from the Lambda Function"
  type        = string
}

variable "lambda_kinesis_activation" {
  description = "Kinesis trigger activation flag"
  type        = bool
  default     = false
}

variable "lambda_api_gateway_activation" {
  description = "API Gateway trigger activation flag"
  type        = bool
  default     = false
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of API Gateway"
  type        = string
  default     = ""
}
