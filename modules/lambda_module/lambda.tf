resource "aws_lambda_layer_version" "main" {
  for_each            = toset(var.lambda_layers_list)
  filename            = "${path.module}/lambda_package/lambda_sample.zip"
  layer_name          = each.key
  compatible_runtimes = [var.lambda_runtime]
}

resource "aws_lambda_function" "main_lambda" {
  for_each      = var.lambda_kinesis_activation ? toset([for el in keys(var.lambda_list_main) : el]) : toset(var.lambda_list_main)
  role          = var.lambda_role
  function_name = each.key
  filename      = "${path.module}/lambda_package/lambda_sample.zip"
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = each.key == var.lambda_with_extra_memory ? 256 : var.lambda_memory_size
  layers        = toset([for index in aws_lambda_layer_version.main : index.arn])

  // dynamic "vpc_config" {
  //   for_each = var.vpc_subnet_ids != null && var.vpc_security_group_ids != null ? [true] : []
  //   content {
  //     security_group_ids = var.lambda_vpc_conf_security_group_ids
  //     subnet_ids         = var.lambda_vpc_conf_subnet_ids
  //   }
  // }
  vpc_config {
    subnet_ids         = var.lambda_vpc_conf_subnet_ids
    security_group_ids = [var.lambda_vpc_conf_security_group_ids]
  }

  dynamic "environment" {
    for_each = length(keys(var.lambda_environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.lambda_environment_variables
    }
  }
}

resource "aws_lambda_event_source_mapping" "kinesis_stream_trigger" {
  for_each          = { for i, v in var.lambda_list_main : i => v if var.lambda_kinesis_activation }
  event_source_arn  = "arn:aws:kinesis:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:stream/${each.value["kinesis_name"]}"
  function_name     = each.key
  starting_position = "LATEST"
  batch_size        = 1
  depends_on        = [aws_lambda_function.main_lambda]
}

resource "aws_lambda_permission" "api_gateway_trigger" {
  for_each      = { for i, v in var.lambda_list_main : i => v if var.lambda_api_gateway_activation }
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = each.value
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
  depends_on    = [aws_lambda_function.main_lambda]
}


resource "aws_cloudwatch_metric_alarm" "lambda_alarm" {
  for_each            = var.lambda_kinesis_activation ? toset([for el in keys(var.lambda_list_main) : el]) : toset(var.lambda_list_main)
  alarm_name          = "${each.key}_lambda_alarm_${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [var.lambda_on_fail_sns_topic]
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  dimensions = {
    FunctionName = each.key
  }
}
