module "real_time_verification_api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "real_time_verification"
  description   = "Real time verification api gateway"
  protocol_type = "HTTP"

  create_api_domain_name = false
  create_default_stage   = false

  authorizers = {
    "lambda" = {
      authorizer_type                   = "REQUEST"
      authorizer_payload_format_version = "2.0"
      authorizer_uri                    = module.real_time_verification_api_gateway_authorizer.lambda_authorizer_invoke_arn
      identity_sources                  = ["$request.header.application"]
      name                              = "real_time_verification_api_authorizer"
    }
  }

  # Routes and integrations
  integrations = {
    "POST /credentials" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:set_api_key"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    }
    "POST /tasks" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:create_task"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "GET /tasks/{id}" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:task_status"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "GET /verification_statistic" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:verification_statistic"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
  }
}

resource "aws_apigatewayv2_stage" "real_time_verification_api" {
  api_id      = module.real_time_verification_api_gateway.apigatewayv2_api_id
  name        = var.api_gateways_stage_name
  auto_deploy = true
}

module "real_time_verification_api_gateway_authorizer" {
  source                    = "../../modules/lambda_authorizer"
  lambda_role               = aws_iam_role.lambda_main.arn
  lambda_authorizer_name    = "real_time_verification_api_authorizer"
  api_gateway_execution_arn = module.real_time_verification_api_gateway.apigatewayv2_api_execution_arn
  authorizer_ip_whitelist   = var.lambda_authorizer_ip_whitelist
}


module "license_service_api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "license_service"
  description   = "License service api gateway"
  protocol_type = "HTTP"

  create_api_domain_name = false
  create_default_stage   = false

  cors_configuration = {
    allow_headers  = ["*"]
    allow_methods  = ["*"]
    allow_origins  = ["*"]
    expose_headers = ["application", "authtoken", "invitationtoken"]
  }

  authorizers = {
    "lambda" = {
      authorizer_type                   = "REQUEST"
      authorizer_payload_format_version = "2.0"
      authorizer_uri                    = module.license_service_api_gateway_authorizer.lambda_authorizer_invoke_arn
      identity_sources                  = ["$request.header.application"]
      name                              = "license_service_api_authorizer"
    }
  }

  # Routes and integrations
  integrations = {
    "POST /accounts/create" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:create_account"
      payload_format_version = "2.0"
    },
    "PUT /accounts/update" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:update_account"
      payload_format_version = "2.0"
    },
    "POST /accounts/block" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:block_account"
      payload_format_version = "2.0"
    },
    "POST /accounts/check_exist_account" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:check_exist_account"
      payload_format_version = "2.0"
    },
    "DELETE /accounts/delete" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:delete_account"
      payload_format_version = "2.0"
    },
    "POST /accounts/get_accounts" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_accounts"
      payload_format_version = "2.0"
    },
    "GET /accounts/get_licenses" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:account_licenses"
      payload_format_version = "2.0"
    },
    "PUT /accounts/unblock" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:unblock_account"
      payload_format_version = "2.0"
    },
    "GET /domain_blacklists" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_domain_blacklists"
      payload_format_version = "2.0"
    },
    "DELETE /domain_blacklists/delete" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:delete_domain_blacklists"
      payload_format_version = "2.0"
    },
    "POST /domain_blacklists/import" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:import_domain_blacklists"
      payload_format_version = "2.0"
    },
    "POST /domain_blacklists/remove" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:remove_domain_blacklists"
      payload_format_version = "2.0"
    },
    "GET /license_histories" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_license_histories"
      payload_format_version = "2.0"
    },
    "POST /licenses" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:create_license"
      payload_format_version = "2.0"
    },
    "POST /licenses/analytics_ids" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:licenses_analytics_ids"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "GET /licenses/license_info" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:license_info"
      payload_format_version = "2.0"
    },
    "POST /licenses/licenses_by_ids" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:licenses_by_ids"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "POST /licenses/remove_users" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:license_remove_users"
      payload_format_version = "2.0"
    },
    "GET /licenses/short_index" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:licenses_short_index"
      payload_format_version = "2.0"
    },
    "GET /licenses/show" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_license"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "PUT /licenses/update" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:update_license"
      payload_format_version = "2.0"
    },
    "GET /users/active_users" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:active_users"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "POST /users/analytics_ids" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:users_analytics_ids"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "PUT /users/block" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:block_user"
      payload_format_version = "2.0"
    },
    "DELETE /users/delete_auto" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:delete_auto_users"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "POST /users/create_auto" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:create_auto_users"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "POST /users/export" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:export_users"
      payload_format_version = "2.0"
    },
    "GET /users/export_by_sso_token" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:export_by_sso_token"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "GET /users/export_demo" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:export_demo_users"
      payload_format_version = "2.0"
    },
    "GET /users/get_api_active_license_users" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_api_active_license_users"
      payload_format_version = "2.0"
    },
    "GET /users/get_api_demo_users" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_demo_users"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "GET /users/get_api_user" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_api_user"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "POST /users/get_api_users_filtered" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_api_users_filtered"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "POST /users/get_by_uids" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_users_by_uids"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "GET /users/get_sso_token" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_sso_token"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "POST /users/get_users_filtered" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_users_filtered"
      payload_format_version = "2.0"
    },
    "POST /users/invite_master_user" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:invite_master_user"
      payload_format_version = "2.0"
    },
    "POST /users/invite_super_user" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:invite_super_user"
      payload_format_version = "2.0"
    },
    "PUT /users/resend_invitation" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:resend_invitation"
      payload_format_version = "2.0"
    },
    "PUT /users/reset_password" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:reset_password"
      payload_format_version = "2.0"
    },
    "GET /users/short_index" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:users_short_index"
      payload_format_version = "2.0"
    },
    "PUT /users/unblock" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:unblock_user"
      payload_format_version = "2.0"
    },
    "PUT /users/update" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:update_user"
      payload_format_version = "2.0"
    },
    "PUT /users/update_active_status" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:update_active_status"
      payload_format_version = "2.0"
    },
    "PUT /users/update_user_credit_limit" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:update_user_credit_limit"
      payload_format_version = "2.0"
    },
    "PUT /users/update_master_user" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:update_master_user"
      payload_format_version = "2.0"
    },
    "PUT /users/update_user_role" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:update_user_role"
      payload_format_version = "2.0"
    },
    "GET /users/user_info" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_user"
      payload_format_version = "2.0"
    },
    "GET /users/user_roles_info" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:user_roles_info"
      payload_format_version = "2.0"
    },
    "POST /users/validate_emails" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:user_roles_info"
      payload_format_version = "2.0"
    },
    "GET /users/{user_id}/show_master_user" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:show_master_user"
      payload_format_version = "2.0"
    },
    "GET /licenses/subtract_credits" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:subtract_credits"
      payload_format_version = "2.0"
    },
    "PUT /licenses/add_credits" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:add_credits"
      payload_format_version = "2.0"
    },
    "PUT /test_status" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:status_check"
      payload_format_version = "2.0"
    },
  }
}

resource "aws_apigatewayv2_stage" "license_service_api" {
  api_id      = module.license_service_api_gateway.apigatewayv2_api_id
  name        = var.api_gateways_stage_name
  auto_deploy = true
}

module "license_service_api_gateway_authorizer" {
  source                    = "../../modules/lambda_authorizer"
  lambda_role               = aws_iam_role.lambda_main.arn
  lambda_authorizer_name    = "license_service_api_gateway_authorizer"
  api_gateway_execution_arn = module.license_service_api_gateway.apigatewayv2_api_execution_arn
  authorizer_ip_whitelist   = var.lambda_authorizer_ip_whitelist
}


module "auth_service_api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "auth_service"
  description   = "Auth service api gateway"
  protocol_type = "HTTP"

  create_api_domain_name = false
  create_default_stage   = false

  cors_configuration = {
    allow_headers  = ["*"]
    allow_methods  = ["*"]
    allow_origins  = ["*"]
    expose_headers = ["application", "authtoken", "invitationtoken"]
  }

  authorizers = {
    "lambda" = {
      authorizer_type                   = "REQUEST"
      authorizer_payload_format_version = "2.0"
      authorizer_uri                    = module.auth_service_api_gateway_authorizer.lambda_authorizer_invoke_arn
      identity_sources                  = ["$request.header.application"]
      name                              = "auth_service_api_authorizer"
    }
  }

  # Routes and integrations
  integrations = {
    "GET /confirm_demo" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:confirm_demo"
      payload_format_version = "2.0"
    }
    "POST /confirm_invitation" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:confirm_invitation"
      payload_format_version = "2.0"
    },
    "POST /invitation" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:infotelligent_invite_user"
      payload_format_version = "2.0"
    },
    "POST /master_passwords" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:create_master_password"
      payload_format_version = "2.0"
    },
    "POST /sign_in" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:sign_in"
      payload_format_version = "2.0"
    },
    "DELETE /sign_out" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:sign_out"
      payload_format_version = "2.0"
    },
    "POST /sign_up" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:sign_up"
      payload_format_version = "2.0"
    },
    "PUT /users" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:personal_update"
      payload_format_version = "2.0"
    },
    "POST /users/change_password" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:change_password"
      payload_format_version = "2.0"
    },
    "POST /users/forgot_password" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:forgot_password"
      payload_format_version = "2.0"
    },
    "PUT /users/recover_password" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:recover_password"
      payload_format_version = "2.0"
    },
    "GET /users/show" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:get_user"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    },
    "GET /validate_invitation" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:validate_invitation"
      payload_format_version = "2.0"
    },
    "GET /validate_invitation" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:validate_invitation"
      payload_format_version = "2.0"
    },
    "GET /validate_reset_password" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:validate_reset_password_token"
      payload_format_version = "2.0"
    },
    "POST /validate_token" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:validate_token"
      payload_format_version = "2.0"
    },
  }
}


resource "aws_apigatewayv2_stage" "auth_service_api" {
  api_id      = module.auth_service_api_gateway.apigatewayv2_api_id
  name        = var.api_gateways_stage_name
  auto_deploy = true
}

module "auth_service_api_gateway_authorizer" {
  source                    = "../../modules/lambda_authorizer"
  lambda_role               = aws_iam_role.lambda_main.arn
  lambda_authorizer_name    = "auth_service_api_authorizer"
  api_gateway_execution_arn = module.auth_service_api_gateway.apigatewayv2_api_execution_arn
  authorizer_ip_whitelist   = var.lambda_authorizer_ip_whitelist
}