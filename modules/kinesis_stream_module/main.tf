terraform {
  required_version = ">= 1.0.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63.0"
    }
  }
}

data "aws_region" "region" {}
data "aws_caller_identity" "identity" {}

resource "aws_kinesis_stream" "main_stream" {
  for_each         = var.kinesis_streams_list
  name             = each.key
  shard_count      = each.value["shards_count"]
  retention_period = var.kinesis_retention_period
}
