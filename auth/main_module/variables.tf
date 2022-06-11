variable "environment" {
  type        = string
  description = "Type of environment"
}

variable "api_gateways_stage_name" {
  type        = string
  description = "Name of stage for all Api Gateways"
}

variable "lambda_on_fail_sns_topic_slack" {
  type        = string
  description = "Arn of SNS topic for Lambda on fail events"
}

variable "lambda_authorizer_ip_whitelist" {
  description = "IP whitelist that used for lambda authorizer"
  type        = list(string)
}

# ---  Secrets

variable "auth_verification_lambda_secret_value" {
  description = "Auth verification main secret for Lambda"
  type        = string
  sensitive   = true
}

variable "auth_license_lambda_secret_value" {
  description = "Auth verification main secret for Lambda"
  type        = string
  sensitive   = true
}

variable "auth_verification_lambda_secret_name" {
  description = "Name of auth verification secret for Lambda"
  type        = string
  default     = "auth-verification-secret"
}

variable "auth_license_lambda_secret_name" {
  description = "Name of auth verification secret for Lambda"
  type        = string
  default     = "auth-license-secret"
}

# ---  VPC
variable "private_cidr_blocks" {
  description = "Available cidr blocks."
  type        = string
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
}

variable "real_time_verification_gateway_lambdas" {
  description = "Lambdas list for Real Time Verification gateway"
  type        = list(string)
}

variable "license_gateway_lambdas" {
  description = "Lambdas list for License gateway"
  type        = list(string)
}

variable "auth_gateway_lambdas" {
  description = "Lambdas list for Auth gateway"
  type        = list(string)
}

variable "license_kinesis_list" {
  description = "License Kinesis List"
  type = map(object({
    shards_count = number
  }))
}

variable "verification_kinesis_list" {
  description = "Verification Kinesis List"
  type = map(object({
    shards_count = number
  }))
}