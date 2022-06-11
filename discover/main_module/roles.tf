# --- JENKINS EC2 ROLES

resource "aws_iam_role" "jenkins_crossaccount_access" {
  name = "jenkins-crossaccount-access-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::666759208159:role/k8s_build_pod_access_role"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {}
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_access" {
  name        = "jenkins-crossaccount-policy-access-to-lambda"
  path        = "/"
  description = "IAM policy for access to AWS Lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "lambda:ListFunctions",
          "lambda:ListLayerVersions",
          "lambda:ListLayers",
          "lambda:PublishLayerVersion",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetLayerVersion"
        ],
        "Resource": ["*"]
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_jenkins_crossaccount_role_1" {
  role       = aws_iam_role.jenkins_crossaccount_access.name
  policy_arn = aws_iam_policy.lambda_access.arn
}


data "aws_iam_policy_document" "assume_role_policy_for_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "opensearch_access_for_lambda" {
  name        = "lambda-access-to-opensearch-policy"
  path        = "/"
  description = "IAM policy for access to OpenSearch"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "es:*"
        ],
        "Resource": ["*"]
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_opensearch_access_policy_to_lambda_role" {
  role       = aws_iam_role.lambda_main.name
  policy_arn = aws_iam_policy.opensearch_access_for_lambda.arn
}

resource "aws_iam_policy" "aws_dynamodb_access_for_lambda" {
  name        = "lambda-access-to-dynamodb-policy"
  path        = "/"
  description = "IAM policy for access to DynamoDB"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan"
        ],
        "Resource": ["arn:aws:dynamodb:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:table/ws-connections"] 
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_access_policy_to_lambda_role" {
  role       = aws_iam_role.lambda_main.name
  policy_arn = aws_iam_policy.aws_dynamodb_access_for_lambda.arn
}

resource "aws_iam_role" "lambda_main" {
  name               = "lambda-main-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_lambda.json
}

data "aws_iam_policy" "aws_ec2_access_for_lambda" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_ec2_access_policy_to_lambda_role" {
  role       = aws_iam_role.lambda_main.name
  policy_arn = data.aws_iam_policy.aws_ec2_access_for_lambda.arn
}

data "aws_iam_policy" "aws_logs_access_for_lambda" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach_logs_access_policy_to_lambda_role" {
  role       = aws_iam_role.lambda_main.name
  policy_arn = data.aws_iam_policy.aws_logs_access_for_lambda.arn
}

// resource "aws_iam_role_policy" "access_secrets_manager" {
//   name = "access-secrets-manager-policy"
//   role = aws_iam_role.lambda_main.name

//   policy = <<EOF
// {
//   "Version": "2012-10-17",
//   "Statement": [
//     {
//       "Action": ["secretsmanager:GetSecretValue"],
//       "Effect": "Allow",
//       "Resource": "arn:aws:secretsmanager:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:secret:*"
//     }
//   ]
// }
// EOF
// }

resource "aws_iam_role_policy" "access_kinesis_and_api_gateway" {
  name = "access-kinesis-and-api-gateway-policy"
  role = aws_iam_role.lambda_main.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["kinesis:PutRecord", "kinesis:GetRecords", "kinesis:GetShardIterator", "kinesis:DescribeStream", "kinesis:ListShards", "kinesis:ListStreams"],
      "Effect": "Allow",
      "Resource": "arn:aws:kinesis:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:stream/*"
    },
    {
      "Action": ["execute-api:Invoke", "execute-api:ManageConnections"],
      "Effect": "Allow",
      "Resource": "arn:aws:execute-api:*:*:*"
    }
  ]
}
EOF
}
