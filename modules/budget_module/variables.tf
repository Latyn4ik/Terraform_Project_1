variable "budget_name" {
  description = "Name of Budget"
  type        = string
}

variable "account_budget_limit" {
  description = "Count of USD for set Budget Limit"
  type        = string
}

variable "service_budget_activation" {
  description = "Activate resources for monitor specified services"
  type        = bool
  default     = false
}

variable "services" {
  description = "List of AWS services to be monitored in terms of costs"
  type = map(object({
    budget_limit = string
  }))
  default = { EC2 = { budget_limit = "5.0" } }
}

variable "email_subscribers_list" {
  description = "Email list of subscribers for budgets notifications"
  type        = list(string)
}
