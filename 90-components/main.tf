module "components"{
    for_each = var.components
    source = "git::https://github.com/venkey27/terraform-roboshop-component.git?ref=main"
    environment = var.environment
    component = each.key                      # key = catalogue
    app_version = each.value.app_version      # each.value = {app_version = "v3"} # each.value.app_version = "v3"
    rule_priority = each.value.rule_priority
} 