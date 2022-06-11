## Providers

| Name | Verison |
|------|---------|
| aws  |  4.1.0  |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| main_vpc_azs | List of AZs for main VPC | `list(string)` | `["us-east-1a", "us-east-1b", "us-east-1c"]` | no |
| lambda_name | Lambda Name | `string` | `lambda_name` | yes |
| lambda_handler | Lambda Handler | `string` | `index.handler` | no |
| lambda_runtime | Lambda Runtime | `string` | `nodejs14.x` | no |
| lambda_timeout | Lambda Timeout period in seconds | `number` | `60` | no |


## Outputs

| Name | Description |
|------|-------------|
|  lambda_fail_sns_topic_arn    | Arn of sns topic for lambda errors messages |