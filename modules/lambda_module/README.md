## Providers

| Name | Verison |
|------|---------|
| aws  |  3.63.0 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| lambda_role | Role for the Lambda |  `string` | n/a | yes |
| lambda_vpc_conf_security_group_ids | Security group IDs for the Lambda VPC configuration | `string` | n/a | yes |
| lambda_vpc_conf_subnet_ids | Subnet IDs for the Lambda VPC configuration | `string` | [""] | yes |
| lambda_handler | Lambda Handler | `string` | `index.handler` | no |
| lambda_runtime | Lambda Runtime | `string` | `nodejs14.x`    | no |
| lambda_timeout | Lambda Timeout period in seconds `number` | `60` | no |
| lambda_memory_size | Lambda memory size | `number` | `128`  | no |
| lambda_with_extra_memory | Lambda functions that needs more memory | `string` | `validate_token` | no |
| lambda_layers_list | List of Lambda functions | `list(string)` | n/a | no |
| lambda_list | List of Lambda functions | `any` | n/a | yes |
| lambda_environment_variables | A map that defines environment variables for the Lambda Function | `map(string)` | {} | no |
| lambda_on_fail_sns_topic | SNS topic for getting on_fail notifications from the Lambda Function | `string` | n/a | yes |
| lambda_kinesis_activation | Kinesis trigger activation flag | bool | false | no |


## Outputs

| Name | Description |
|------|-------------|
| api_invoke_url | Invoke URL of API Gateway |




