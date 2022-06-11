module "elastic_kinesis_streams" {
  source               = "../../modules/kinesis_stream_module"
  kinesis_streams_list = var.elastic_kinesis_list
}

module "elastic_kinesis_lambdas" {
  source = "../../modules/lambda_module"

  environment               = var.environment
  lambda_kinesis_activation = true
  lambda_list_main          = var.elastic_kinesis_lambda_list
  lambda_layers_list        = ["elastic_main_layer"]
  lambda_role               = aws_iam_role.lambda_main.arn
  lambda_on_fail_sns_topic  = var.lambda_on_fail_sns_topic_slack
  lambda_environment_variables = {
    elastic_domain = "https://${aws_elasticsearch_domain.opensearch_main_domain.endpoint}/"
  }
  lambda_vpc_conf_subnet_ids         = [module.vpc.private_subnets[0]]
  lambda_vpc_conf_security_group_ids = aws_security_group.main.id
  depends_on                         = [module.elastic_kinesis_streams]
}
