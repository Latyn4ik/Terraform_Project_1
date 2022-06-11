

module "elastic_lambda" {
  source                        = "../../modules/lambda_module"
  environment                   = var.environment
  lambda_api_gateway_activation = true
  api_gateway_execution_arn     = module.elasticsearch_api_gateway.apigatewayv2_api_execution_arn
  lambda_list_main              = var.elastic_lambda_list
  lambda_layers_list            = ["elastic_queue_helper"]
  lambda_role                   = aws_iam_role.lambda_main.arn
  lambda_on_fail_sns_topic      = var.lambda_on_fail_sns_topic_slack
  lambda_environment_variables = {
    elastic_domain = "https://${aws_elasticsearch_domain.opensearch_main_domain.endpoint}/"
  }
  lambda_vpc_conf_subnet_ids         = [module.vpc.private_subnets[0]]
  lambda_vpc_conf_security_group_ids = aws_security_group.main.id
}

module "websocket_api_gateway_lambdas" {
  source                             = "../../modules/lambda_module"
  environment                        = var.environment
  lambda_api_gateway_activation      = true
  api_gateway_execution_arn          = module.websocket_api_gateway.apigatewayv2_api_execution_arn
  lambda_list_main                   = var.websocket_api_gateway_lambdas_list
  lambda_role                        = aws_iam_role.lambda_main.arn
  lambda_on_fail_sns_topic           = var.lambda_on_fail_sns_topic_slack
  lambda_vpc_conf_subnet_ids         = [module.vpc.private_subnets[0]]
  lambda_vpc_conf_security_group_ids = aws_security_group.main.id
}

module "ws_send_message_api_gateway_lambdas" {
  source                             = "../../modules/lambda_module"
  environment                        = var.environment
  lambda_api_gateway_activation      = true
  api_gateway_execution_arn          = module.ws_send_message_api_gateway.apigatewayv2_api_execution_arn
  lambda_list_main                   = var.ws_send_message_api_gateway_lambdas_list
  lambda_layers_list                 = ["ws_main_layer"]
  lambda_role                        = aws_iam_role.lambda_main.arn
  lambda_on_fail_sns_topic           = var.lambda_on_fail_sns_topic_slack
  lambda_vpc_conf_subnet_ids         = [module.vpc.private_subnets[0]]
  lambda_vpc_conf_security_group_ids = aws_security_group.main.id
}