locals {
  monitoring_channel_ids = {
    for k, v in var.budgets_input : k => [
      for email in v.email_ids : google_monitoring_notification_channel.notification_channel[email].id
    ]
  }
}

resource "google_billing_budget" "budget" {
  for_each        = var.budgets_input
  billing_account = each.value.billing_account
  display_name    = each.value.display_name

  budget_filter {
    projects               = each.value.projects
    credit_types_treatment = each.value.credit_types_treatment
    services               = each.value.services
    credit_types           = each.value.credit_types
    labels                 = { (each.value.label_key) = (each.value.label_value) }
    # resource_ancestors     = ["organizations/123456789"]
  }

  dynamic "threshold_rules" {
    for_each = each.value.threshold_config != null ? each.value.threshold_config : []
    content {
      spend_basis       = threshold_rules.value.spend_basis
      threshold_percent = threshold_rules.value.threshold_percent
    }
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = each.value.amount
    }
  }

  all_updates_rule {
    monitoring_notification_channels = local.monitoring_channel_ids[each.key]
    disable_default_iam_recipients   = true
  }

}

resource "google_monitoring_notification_channel" "notification_channel" {
  for_each     = var.email_ids_list
  display_name = each.value
  type         = "email"

  labels = {
    email_address = each.value
  }
}
