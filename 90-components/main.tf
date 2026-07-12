module "components"{
    for_each = var.components
    source = "../../terraform-roboshop-component"
    environment = var.environment
    component = each.key                      # key = catalogue
    app_version = each.value.app_version      # each.value = {app_version = "v3"} # each.value.app_version = "v3"
} 