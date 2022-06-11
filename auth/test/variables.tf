variable "auth_verification_main_lambda_secret" {
  sensitive = true
}

variable "auth_license_main_lambda_secret" {
  sensitive = true
}

variable "notification_slack_webhook_url" {
  sensitive = true
}

variable "private_cidr_blocks" {
  description = "Available cidr blocks."
  type        = string
  default     = "20.0.0.0/16"
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default = [
    "20.0.1.0/24",
    "20.0.2.0/24",
  ]
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default = [
    "20.0.101.0/24",
    "20.0.102.0/24",
  ]
}

variable "api_endpoints_api_gateway_1" { # license_gateway
  type = any
  default = {
    "/accounts/create"                    = { post = "create_account" }
    "/accounts/update"                    = { put = "update_account" }
    "/accounts/block"                     = { post = "block_account" }
    "/accounts/check_exist_account"       = { post = "check_exist_account" }
    "/accounts/delete"                    = { delete = "delete_account" }
    "/accounts/get_accounts"              = { post = "get_accounts" }
    "/accounts/get_licenses"              = { get = "account_licenses" }
    "/accounts/unblock"                   = { put = "unblock_account" }
    "/domain_blacklists"                  = { get = "get_domain_blacklists" }
    "/domain_blacklists/delete"           = { delete = "delete_domain_blacklists" }
    "/domain_blacklists/import"           = { post = "import_domain_blacklists" }
    "/domain_blacklists/remove"           = { post = "remove_domain_blacklists" }
    "/license_histories"                  = { get = "get_license_histories" }
    "/licenses"                           = { post = "create_license" }
    "/licenses/analytics_ids"             = { post = "licenses_analytics_ids" }
    "/licenses/license_info"              = { get = "license_info" }
    "/licenses/licenses_by_ids"           = { post = "licenses_by_ids" }
    "/licenses/remove_users"              = { post = "license_remove_users" }
    "/licenses/short_index"               = { get = "licenses_short_index" }
    "/licenses/show"                      = { get = "get_license" }
    "/licenses/update"                    = { get = "update_license" }
    "/users/active_users"                 = { get = "active_users" }
    "/users/analytics_ids"                = { post = "users_analytics_ids" }
    "/users/block"                        = { put = "block_user" }
    "/users/delete_auto"                  = { delete = "delete_auto_users" }
    "/users/create_auto"                  = { post = "create_auto_users" }
    "/users/export"                       = { post = "export_users" }
    "/users/export_by_sso_token"          = { get = "export_by_sso_token" }
    "/users/export_demo"                  = { post = "export_demo_users" }
    "/users/get_api_active_license_users" = { get = "get_api_active_license_users" }
    "/users/get_api_demo_users"           = { get = "get_demo_users" }
    "/users/get_api_user"                 = { get = "get_api_user" }
    "/users/get_api_users_filtered"       = { post = "get_api_users_filtered" }
    "/users/get_by_uids"                  = { post = "get_users_by_uids" }
    "/users/get_sso_token"                = { get = "get_sso_token" }
    "/users/get_users_filtered"           = { post = "get_users_filtered" }
    "/users/invite_master_user"           = { post = "invite_master_user" }
    "/users/invite_super_user"            = { post = "invite_super_user" }
    "/users/resend_invitation"            = { put = "resend_invitation" }
    "/users/reset_password"               = { put = "reset_password" }
    "/users/short_index"                  = { get = "users_short_index" }
    "/users/unblock"                      = { put = "unblock_user" }
    "/users/update"                       = { put = "update_user" }
    "/users/update_active_status"         = { put = "update_active_status" }
    "/users/update_user_credit_limit"     = { put = "update_user_credit_limit" }
    "/users/update_master_user"           = { put = "update_master_user" }
    "/users/update_user_role"             = { put = "update_user_role" }
    "/users/user_info"                    = { get = "get_user" }
    "/users/user_roles_info"              = { post = "user_roles_info" }
    "/users/validate_emails"              = { post = "validate_emails" }
    "/users/{user_id}/show_master_user"   = { get = "show_master_user" }
    "/licenses/subtract_credits"          = { put = "subtract_credits" }
    "/licenses/add_credits"               = { put = "add_credits" }
    "/test_status"                        = { put = "status_check" }
  }
}

variable "api_endpoints_api_gateway_2" { # auth_gateway
  type = any
  default = {
    "/confirm_demo"            = { get = "confirm_demo" }
    "/confirm_invitation"      = { post = "confirm_invitation" }
    "/invitation"              = { post = "infotelligent_invite_user" }
    "/master_passwords"        = { post = "create_master_password" }
    "/sign_in"                 = { post = "sign_in" }
    "/sign_out"                = { delete = "sign_out" }
    "/sign_up"                 = { post = "sign_up" }
    "/users"                   = { put = "personal_update" }
    "/users/change_password"   = { post = "change_password" }
    "/users/forgot_password"   = { post = "forgot_password" }
    "/users/recover_password"  = { put = "recover_password" }
    "/users/show"              = { get = "get_user" }
    "/validate_invitation"     = { get = "validate_invitation" }
    "/validate_reset_password" = { get = "validate_reset_password_token" }
    "/validate_token"          = { post = "validate_token" }
  }
}

variable "api_endpoints_api_gateway_3" { # real_time_verification_gateway
  type = any
  default = {
    "/credentials"            = { post = "set_api_key" }
    "/tasks"                  = { post = "create_task" }
    "/tasks/{id}"             = { get = "task_status" }
    "/verification_statistic" = { get = "verification_statistic" }
  }
}

locals {
  lambda_list_raw_1    = flatten([for endpoint, spec in var.api_endpoints_api_gateway_1 : [for lambda in spec : lambda]])
  lambda_list_raw_2    = flatten([for endpoint, spec in var.api_endpoints_api_gateway_2 : [for lambda in spec : lambda]])
  lambda_list_concated = concat(local.lambda_list_raw_1, local.lambda_list_raw_2)
  lambda_list_dynamic  = distinct(local.lambda_list_concated)
  lambda_list_filtred  = [for i in local.lambda_list_dynamic : i]
}

locals {
  lambda_list_raw_3     = flatten([for endpoint, spec in var.api_endpoints_api_gateway_3 : [for lambda in spec : lambda]])
  lambda_list_dynamic_3 = distinct(local.lambda_list_raw_3)
  lambda_list_filtred_3 = [for i in local.lambda_list_dynamic_3 : i]
}


variable "verification_kinesis_list" {
  type = map(object({
    shards_count = number
  }))
  default = {
    "publish" = {
      shards_count = 1
    }
    "real_time_verification" = {
      shards_count = 1
    }
    "task_queue" = {
      shards_count = 1
    }
  }
}

variable "license_kinesis_list" {
  type = map(object({
    shards_count = number
  }))
  default = {
    "third_party_api_stream" = {
      shards_count = 1
    }
  }
}