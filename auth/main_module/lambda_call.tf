module "auth_gateway_lambdas" {
  source                             = "../../modules/lambda_module"
  environment                        = var.environment
  lambda_api_gateway_activation      = true
  api_gateway_execution_arn          = module.auth_service_api_gateway.apigatewayv2_api_execution_arn
  lambda_list_main                   = var.auth_gateway_lambdas
  lambda_layers_list                 = ["main_layer", "queue_helper", "s3_module"]
  lambda_role                        = aws_iam_role.lambda_main.arn
  lambda_on_fail_sns_topic           = var.lambda_on_fail_sns_topic_slack
  lambda_environment_variables       = { secret_key = var.auth_license_lambda_secret_name }
  lambda_vpc_conf_subnet_ids         = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  lambda_vpc_conf_security_group_ids = aws_security_group.main.id
}

module "license_gateway_lambdas" {
  source                             = "../../modules/lambda_module"
  environment                        = var.environment
  lambda_api_gateway_activation      = true
  api_gateway_execution_arn          = module.license_service_api_gateway.apigatewayv2_api_execution_arn
  lambda_list_main                   = var.license_gateway_lambdas
  lambda_layers_list                 = ["main_layer", "queue_helper", "s3_module"]
  lambda_role                        = aws_iam_role.lambda_main.arn
  lambda_on_fail_sns_topic           = var.lambda_on_fail_sns_topic_slack
  lambda_environment_variables       = { secret_key = var.auth_license_lambda_secret_name }
  lambda_vpc_conf_subnet_ids         = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  lambda_vpc_conf_security_group_ids = aws_security_group.main.id
}

module "real_time_verification_gateway_lambdas" {
  source                             = "../../modules/lambda_module"
  environment                        = var.environment
  lambda_api_gateway_activation      = true
  api_gateway_execution_arn          = module.real_time_verification_api_gateway.apigatewayv2_api_execution_arn
  lambda_list_main                   = var.real_time_verification_gateway_lambdas
  lambda_layers_list                 = ["publisher", "shared", "stream_integration"]
  lambda_role                        = aws_iam_role.lambda_main.arn
  lambda_on_fail_sns_topic           = var.lambda_on_fail_sns_topic_slack
  lambda_environment_variables       = { secret_key = var.auth_verification_lambda_secret_name }
  lambda_vpc_conf_subnet_ids         = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  lambda_vpc_conf_security_group_ids = aws_security_group.main.id
}