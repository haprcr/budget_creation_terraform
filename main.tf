locals {
  budgets_input = {
    for k, v in var.budgets_config :
    "${k}.${v.display_name}" => v
  }

  email_ids = distinct(flatten([for k, v in local.budgets_input: v.email_ids]))
}

module "budget_creation" {
  source         = "./module/budget"
  budgets_input  = local.budgets_input
  email_ids_list = local.email_ids
}


