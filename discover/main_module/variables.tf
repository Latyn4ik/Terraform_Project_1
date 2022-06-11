variable "environment" {
  type        = string
  description = "Type of environment"
}

variable "api_gateways_stage_name" {
  type        = string
  description = "Name of stage for all Api Gateways"
}

variable "lambda_authorizer_ip_whitelist" {
  description = "IP whitelist that used for lambda authorizer"
  type        = list(string)
}

variable "elastic_kinesis_list" {
  type = map(object({
    shards_count = number
  }))
}

variable "elastic_lambda_list" {
  type = list(string)
}

variable "websocket_api_gateway_lambdas_list" {
  type = list(string)
}

variable "ws_send_message_api_gateway_lambdas_list" {
  type = list(string)
}

variable "elastic_kinesis_lambda_list" {
  type = map(object({
    kinesis_name         = string
    reserved_concurrency = number
  }))
}

variable "lambda_on_fail_sns_topic_slack" {
  type        = string
  description = "Arn of SNS topic for Lambda on fail events"
}

variable "opensearch_instance_count" {
  description = "Count of instances for Opensearch Domain"
  type        = string
  default     = 2
}

variable "opensearch_instance_type" {
  description = "Type of instances for  Opensearch Domain"
  type        = string
  default     = "m5.large.elasticsearch"
}

variable "opensearch_master_username" {
  description = "Master username for  Opensearch Domain"
  type        = string
  sensitive   = true
}

variable "opensearch_master_password" {
  description = "Master password for  Opensearch Domain"
  type        = string
  sensitive   = true
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
