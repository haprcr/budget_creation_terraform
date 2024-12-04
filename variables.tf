variable "budgets_config" {
  description = "Budget configuration inputs"
  type = map(object({
    billing_account        = string
    display_name           = string
    resource_ancestors     = optional(list(string), [])
    projects               = optional(list(string), [])
    services               = optional(list(string), [])
    label_key              = string
    label_value            = string
    calendarPeriod         = optional(string, "MONTH")
    credit_types_treatment = optional(string, "INCLUDE_ALL_CREDITS")
    credit_types           = optional(list(string), [])
    amount                 = string
    threshold_config = list(object({
      threshold_percent = number
      spend_basis       = optional(string, "CURRENT_SPEND")
    }))
    email_ids = list(string)
  }))
}


