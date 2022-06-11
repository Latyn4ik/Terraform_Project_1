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
    bucket = "terraform-state-bucket-auth-staging-0015"
    key    = "terraform.tfstate"
  }

}

provider "aws" {
  region = "us-east-1"
}

data "aws_region" "region" {}
data "aws_caller_identity" "identity" {}

module "main_module" {
  source                                 = "../main_module"
  environment                            = "staging"
  api_gateways_stage_name                = "staging"
  lambda_on_fail_sns_topic_slack         = module.lambda_on_fail_slack_notify.slack_topic_arn
  auth_verification_lambda_secret_value  = var.auth_verification_main_lambda_secret
  auth_license_lambda_secret_value       = var.auth_license_main_lambda_secret
  private_cidr_blocks                    = var.private_cidr_blocks
  private_subnet_cidr_blocks             = var.private_subnet_cidr_blocks
  public_subnet_cidr_blocks              = var.public_subnet_cidr_blocks
  license_gateway_lambdas                = local.license_lambda_list_filtred
  auth_gateway_lambdas                   = local.auth_lambda_list_filtred
  real_time_verification_gateway_lambdas = local.real_time_verification_lambda_list_filtred
  verification_kinesis_list              = var.verification_kinesis_list
  license_kinesis_list                   = var.license_kinesis_list
  lambda_authorizer_ip_whitelist         = var.lambda_authorizer_ip_whitelist
}

module "budget_module" {
  source                    = "../../modules/budget_module"
  budget_name               = "auth_staging_main_budget"
  account_budget_limit      = "300.0"
  service_budget_activation = true
  services = {
    Opensearch = {
      budget_limit = "5.0"
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