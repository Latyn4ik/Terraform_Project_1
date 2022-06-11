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
    bucket = "terraform-state-bucket-discover-prod-0010"
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
  environment                              = "prod"
  api_gateways_stage_name                  = "p"
  opensearch_instance_count                = 5
  opensearch_instance_type                 = "m5.2xlarge.elasticsearch"
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
}

module "budget_module" {
  source                    = "../../modules/budget_module"
  budget_name               = "discover_prod_main_budget"
  account_budget_limit      = "3000.0"
  service_budget_activation = true
  services = {
    Opensearch = {
      budget_limit = "2500.0"
    }
  }
  email_subscribers_list = ["ilatincev@gmail.com"]
}

module "lambda_on_fail_slack_notify" {
  source            = "terraform-aws-modules/notify-slack/aws"
  version           = "~> 4.0"
  sns_topic_name    = "lambda_on_fail"
  slack_webhook_url = var.notification_slack_webhook_url
  slack_channel     = "aws-notifications"
  slack_username    = "tc_bot"
}
