## Providers

| Name | Verison |
|------|---------|
| aws  |  3.63.0 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| budget_name | Name of Budget | `string` | n/a | yes |
| account_budget_limit | Count of USD for set Budget Limit | `string` | n/a | yes |
| service_budget_activation | Activate resources for monitor specified services | `bool` | false | no |
| services | List of AWS services to be monitored in terms of costs | `map(object({budget_limit = string}))` | n/a | no |
| email_subscribers_list | Email list of subscribers for budgets notifications | list(string) | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
|      |             |