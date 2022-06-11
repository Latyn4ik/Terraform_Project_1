variable "notification_slack_webhook_url" {
  sensitive = true
}

variable "opensearch_master_username" {
  sensitive = true
}

variable "opensearch_master_password" {
  sensitive = true
}

variable "private_cidr_blocks" {
  description = "Available cidr blocks."
  type        = string
  default     = "21.0.0.0/16"
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default = [
    "21.0.1.0/24",
    "21.0.2.0/24",
  ]
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default = [
    "21.0.101.0/24",
    "21.0.102.0/24",
  ]
}

variable "elastic_kinesis_list" {
  type = map(object({
    shards_count = number
  }))
  default = {
    "contact_reindex" = {
      shards_count = 1
    }
    "city_reindex" = {
      shards_count = 1
    }
    "state_reindex" = {
      shards_count = 1
    }
    "country_reindex" = {
      shards_count = 1
    }
    "sic_code_reindex" = {
      shards_count = 1
    }
    "technology_reindex" = {
      shards_count = 1
    }
    "company_reindex" = {
      shards_count = 1
    }
    "contacts_bulk_reindex" = {
      shards_count = 1
    }
    "contacts_bulk_delete" = {
      shards_count = 1
    }
    "contacts_erase_emails" = {
      shards_count = 1
    }
  }
}

variable "ws_send_message_api_gateway_lambdas_list" {
  type    = list(string)
  default = ["wsSendMessage", "wsCloseMessage"]
}

variable "websocket_api_gateway_lambdas_list" {
  type    = list(string)
  default = ["wsConnect", "wsDisconnect"]
}

variable "api_endpoints_api_gateway_1" {
  type = any
  default = {
    "/send_data_to_stream" = { post = "send_to_reindex_stream" }
  }
}

locals {
  lambda_list_raw_1    = flatten([for endpoint, spec in var.api_endpoints_api_gateway_1 : [for lambda in spec : lambda]])
  lambda_list_concated = concat(local.lambda_list_raw_1)
  lambda_list_dynamic  = distinct(local.lambda_list_concated)
  lambda_list_filtred  = [for i in local.lambda_list_dynamic : i]
}

variable "elastic_kinesis_lambda_list" {
  type = map(object({
    kinesis_name         = string
    reserved_concurrency = number
  }))
  default = {
    "reindex_contact" = {
      kinesis_name = "contact_reindex"
    reserved_concurrency = 1 }
    "reindex_city" = {
      kinesis_name = "city_reindex"
    reserved_concurrency = 1 }
    "reindex_state" = {
      kinesis_name = "state_reindex"
    reserved_concurrency = 1 }
    "reindex_country" = {
      kinesis_name = "country_reindex"
    reserved_concurrency = 1 }
    "reindex_sic_code" = {
      kinesis_name = "sic_code_reindex"
    reserved_concurrency = 1 }
    "reindex_technology" = {
      kinesis_name = "technology_reindex"
    reserved_concurrency = 1 }
    "reindex_company" = {
      kinesis_name = "company_reindex"
    reserved_concurrency = 1 }
    "bulk_reindex_contacts" = {
      kinesis_name = "contacts_bulk_reindex"
    reserved_concurrency = 1 }
    "bulk_delete_contacts" = {
      kinesis_name = "contacts_bulk_delete"
    reserved_concurrency = 1 }
    "bulk_erase_contacts_emails" = {
      kinesis_name = "contacts_erase_emails"
    reserved_concurrency = 1 }
  }
}