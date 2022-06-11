module "verification_kinesis_streams" {
  source               = "../../modules/kinesis_stream_module"
  kinesis_streams_list = var.verification_kinesis_list
}

module "verification_kinesis_lambda" {
  source = "../../modules/lambda_module"

  environment               = var.environment
  lambda_kinesis_activation = true
  lambda_list_main = {
    "fill_task_queue" = {
      kinesis_name         = "task_queue"
      reserved_concurrency = "1"
    }
    "process_linkedin" = {
      kinesis_name         = "real_time_verification"
      reserved_concurrency = "20"
    }
    "publish_file" = {
      kinesis_name         = "publish"
      reserved_concurrency = "-1"
    }
  }
  lambda_layers_list                 = ["publisher", "shared", "stream_integration"]
  lambda_role                        = aws_iam_role.lambda_main.arn
  lambda_on_fail_sns_topic           = var.lambda_on_fail_sns_topic_slack
  lambda_environment_variables       = { secret_key = var.auth_verification_lambda_secret_name }
  lambda_vpc_conf_subnet_ids         = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  lambda_vpc_conf_security_group_ids = aws_security_group.main.id
  depends_on                         = [module.verification_kinesis_streams]
}

module "license_kinesis_streams" {
  source               = "../../modules/kinesis_stream_module"
  kinesis_streams_list = var.license_kinesis_list
}

module "license_kinesis_lambda" {
  source = "../../modules/lambda_module"

  environment               = var.environment
  lambda_kinesis_activation = true
  lambda_list_main = {
    "process_third_party_requests" = {
      kinesis_name         = "third_party_api_stream"
      reserved_concurrency = "-1"
    }
  }
  lambda_layers_list                 = ["main_layer", "queue_helper", "s3_module"]
  lambda_role                        = aws_iam_role.lambda_main.arn
  lambda_on_fail_sns_topic           = var.lambda_on_fail_sns_topic_slack
  lambda_environment_variables       = { secret_key = var.auth_license_lambda_secret_name }
  lambda_vpc_conf_subnet_ids         = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  lambda_vpc_conf_security_group_ids = aws_security_group.main.id
  depends_on                         = [module.license_kinesis_streams]
}
