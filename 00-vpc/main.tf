module "vpc" {  # callig module
    #source = "../terraform-aws-vpc" 
    source = "git::https://github.com/venkey27/terraform-aws-vpc.git?ref=main"
    project = var.project
    environment = var.environment
    is_peering_required = false
    
}


# module will not have provider
# project repos should have providers, call the mdule through source
# send the required variables values