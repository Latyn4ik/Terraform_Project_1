terraform {
  required_version = ">= 1.0.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.1.0"
    }
  }

  backend "s3" {
    region = "us-east-1"
    bucket = "terraform-state-bucket-discover-staging-0012"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_region" "region" {}
data "aws_caller_identity" "identity" {}

module "main_module" {
  source                                   = "../main_module"
  environment                              = "staging"
  api_gateways_stage_name                  = "staging"
  opensearch_instance_count                = 2
  opensearch_instance_type                 = "m5.large.elasticsearch"
  opensearch_master_username               = var.opensearch_master_username
  opensearch_master_password               = var.opensearch_master_password
  lambda_on_fail_sns_topic_slack           = module.lambda_on_fail_slack_notify.slack_topic_arn
  private_cidr_blocks                      = var.private_cidr_blocks
  private_subnet_cidr_blocks               = var.private_subnet_cidr_blocks
  public_subnet_cidr_blocks                = var.public_subnet_cidr_blocks
  elastic_kinesis_list                     = var.elastic_kinesis_list
  elastic_kinesis_lambda_list              = var.elastic_kinesis_lambda_list
  ws_send_message_api_gateway_lambdas_list = var.ws_send_message_api_gateway_lambdas_list
  websocket_api_gateway_lambdas_list       = var.websocket_api_gateway_lambdas_list
  elastic_lambda_list                      = local.lambda_list_filtred
  lambda_authorizer_ip_whitelist           = var.lambda_authorizer_ip_whitelist
}

module "budget_module" {
  source                    = "../../modules/budget_module"
  budget_name               = "discover_staging_main_budget"
  account_budget_limit      = "520.0"
  service_budget_activation = false
  email_subscribers_list    = ["ilatincev@gmail.com"]
}

module "lambda_on_fail_slack_notify" {
  source            = "terraform-aws-modules/notify-slack/aws"
  version           = "~> 4.0"
  sns_topic_name    = "lambda_on_fail"
  slack_webhook_url = var.notification_slack_webhook_url
  slack_channel     = "aws-notifications"
  slack_username    = "tc_bot"
}
