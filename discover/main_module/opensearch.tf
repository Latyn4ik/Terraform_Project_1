resource "aws_cloudwatch_log_group" "es_application_logs" {
  name = "es-application-logs"
}

resource "aws_cloudwatch_log_group" "es_audit_logs" {
  name = "es-audit-logs"
}

resource "aws_cloudwatch_log_group" "es_index_slow_logs" {
  name = "es-index-slow-logs"
}

resource "aws_cloudwatch_log_group" "es_search_slow_logs" {
  name = "es-search-slow-logs"
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_logs_policy" {
  policy_name = "example"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_elasticsearch_domain" "opensearch_main_domain" {
  domain_name = "discovery-es-${var.environment}"
  elasticsearch_version = "OpenSearch_1.1"

  lifecycle {
    prevent_destroy = true
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 512
  }
  cluster_config {
    instance_count = var.opensearch_instance_count
    instance_type = var.opensearch_instance_type
  }
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_application_logs.arn
    enabled = true
    log_type = "ES_APPLICATION_LOGS"
  }
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_audit_logs.arn
    enabled = true
    log_type = "AUDIT_LOGS"
  }
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_index_slow_logs.arn
    enabled = true
    log_type = "INDEX_SLOW_LOGS"
  }
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_search_slow_logs.arn
    enabled = true
    log_type = "SEARCH_SLOW_LOGS"
  }

  auto_tune_options {
    desired_state = "ENABLED"
    rollback_on_disable = "NO_ROLLBACK"
  }
  node_to_node_encryption {
    enabled = true
  }
  encrypt_at_rest {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_options = {
    "indices.fielddata.cache.size" = 30
    "indices.query.bool.max_clause_count" = 4096
  }

  advanced_security_options {
    enabled = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name = var.opensearch_master_username
      master_user_password = var.opensearch_master_password
    }
  }

  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:us-east-1:${data.aws_caller_identity.identity.account_id}:domain/discovery-es-${var.environment}/*"
    }
  ]
}
POLICY
}
