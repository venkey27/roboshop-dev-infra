output "vpc_id" {                     # module.vpc came form main.tf file in roboshop-dev-infra/00-vpc/main.tf
    value = module.vpc.vpc_id         # vpc_id is coming from .terraform/vpc/outputs.tf file
}

output "public_subnet_ids" {
    value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
    value = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
    value = module.vpc.database_subnet_ids
}