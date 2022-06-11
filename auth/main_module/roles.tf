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

resource "aws_iam_role_policy" "lambda_access" {
  name = "jenkins-crossaccount-policy-access-to-lambda"
  role = aws_iam_role.jenkins_crossaccount_access.name

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

resource "aws_iam_role_policy" "s3_access" {
  name = "lambda-access-policy-to-s3"
  role = aws_iam_role.lambda_main.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource": ["arn:aws:s3:::infotelligent-verification", "arn:aws:s3:::infotelligent-verification/*"]
      }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_main" {
  name               = "lambda-main-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_lambda.json
}

data "aws_iam_policy" "aws_ec2_access_policy_for_lambda" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_ec2_access_policy_to_lambda_role" {
  role       = aws_iam_role.lambda_main.name
  policy_arn = data.aws_iam_policy.aws_ec2_access_policy_for_lambda.arn
}

data "aws_iam_policy" "aws_logs_access_policy_for_lambda" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach_logs_access_policy_to_lambda_role" {
  role       = aws_iam_role.lambda_main.name
  policy_arn = data.aws_iam_policy.aws_logs_access_policy_for_lambda.arn
}

resource "aws_iam_role_policy" "access_to_secrets_manager" {
  name = "access-secrets-manager-policy"
  role = aws_iam_role.lambda_main.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["secretsmanager:GetSecretValue"],
      "Effect": "Allow",
      "Resource": "arn:aws:secretsmanager:${data.aws_region.region.name}:${data.aws_caller_identity.identity.account_id}:secret:*"
    }
  ]
}
EOF
}

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
