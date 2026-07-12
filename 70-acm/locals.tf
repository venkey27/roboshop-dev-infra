locals {
    common_tags = {
        Project = var.project
        Environment =  var.environment
        Terraform = true # so identify that this resurce is made by using terraform
        Name = local.common_name
    }
    common_name = "${var.project}-${var.environment}" # roboshop-dev
}    