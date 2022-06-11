resource "aws_budgets_budget" "budget_account" {
  name         = "${var.budget_name} Account Monthly Budget"
  budget_type  = "COST"
  limit_amount = var.account_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.email_subscribers_list
  }
}

resource "aws_budgets_budget" "budget_resources" {
  for_each     = { for k, v in var.services : k => v if var.service_budget_activation }
  name         = "${var.budget_name} ${each.key} Monthly Budget"
  budget_type  = "COST"
  limit_amount = each.value.budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filters = {
    Service = lookup(local.aws_services, each.key)
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.email_subscribers_list
  }
}
