module "elasticsearch_api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "elasticsearch-api"
  description   = "Elasticsearch api gateway"
  protocol_type = "HTTP"

  create_api_domain_name = false
  create_default_stage   = false

  authorizers = {
    "lambda" = {
      authorizer_type                   = "REQUEST"
      authorizer_payload_format_version = "2.0"
      authorizer_uri                    = module.elasticsearch_api_gateway_authorizer.lambda_authorizer_invoke_arn
      identity_sources                  = ["$request.header.application"]
      name                              = "elasticsearch_api_authorizer"
    }
  }

  # Routes and integrations
  integrations = {
    "POST /send_data_to_stream" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:send_to_reindex_stream"
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda"
    }
  }
}

resource "aws_apigatewayv2_stage" "elasticsearch_api" {
  api_id      = module.elasticsearch_api_gateway.apigatewayv2_api_id
  name        = var.api_gateways_stage_name
  auto_deploy = true
}

module "elasticsearch_api_gateway_authorizer" {
  source                    = "../../modules/lambda_authorizer"
  lambda_role               = aws_iam_role.lambda_main.arn
  lambda_authorizer_name    = "elasticsearch_api_authorizer"
  api_gateway_execution_arn = module.elasticsearch_api_gateway.apigatewayv2_api_execution_arn
  authorizer_ip_whitelist   = var.lambda_authorizer_ip_whitelist
}

module "websocket_api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name                       = "websocket-api"
  description                = "WS api gateway"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"

  create_api_domain_name = false
  create_default_stage   = false

  integrations = {
    "$connect" = {
      integration_type = "AWS_PROXY"
      // route_key         = "$connect"
      lambda_arn = "arn:aws:apigateway:${data.aws_region.region.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:wsConnect/invocations"
    },
    "$disconnect" = {
      integration_type = "AWS_PROXY"
      // route_key         = "$disconnect"
      lambda_arn = "arn:aws:apigateway:${data.aws_region.region.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:wsDisconnect/invocations"
    },
  }
}

resource "aws_apigatewayv2_stage" "websocket_api" {
  api_id      = module.websocket_api_gateway.apigatewayv2_api_id
  name        = var.api_gateways_stage_name
  auto_deploy = true
}


module "ws_send_message_api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "ws-send-message"
  description   = "WS api gateway"
  protocol_type = "HTTP"

  create_api_domain_name = false
  create_default_stage   = false

  cors_configuration = {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Routes and integrations
  integrations = {
    "POST /wsSendMessage" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:wsSendMessage"
      payload_format_version = "2.0"
    }
    "POST /wsCloseMessage" = {
      lambda_arn             = "arn:aws:lambda:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:function:wsCloseMessage"
      payload_format_version = "2.0"
    },
  }
}

resource "aws_apigatewayv2_stage" "ws_send_message" {
  api_id      = module.ws_send_message_api_gateway.apigatewayv2_api_id
  name        = var.api_gateways_stage_name
  auto_deploy = true
}