resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project}/${var.environment}/vpc_id"  # /roboshop/dev/vpc_id will be created in aws ssm parameter store 
  type  = "String"
  value = module.vpc.vpc_id         # vpc_id is coming from outputs.tf file and store in aws ssm parameter store
  overwrite = true           # overwrite = true is used to overwrite the existing value in aws ssm parameter store if it already exists
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project}/${var.environment}/public_subnet_ids"  # /roboshop/dev/public_subnet_ids will be created in aws ssm parameter store 
  type  = "String"                        # join function is used to convert list to string and store in aws ssm parameter store
  value = join("," ,module.vpc.public_subnet_ids) # public_subnet_ids is coming from outputs.tf file and store in aws ssm parameter store
  overwrite = true           # overwrite = true is used to overwrite the existing value in aws ssm parameter store if it already exists
}       

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project}/${var.environment}/private_subnet_ids"  # /roboshop/dev/private_subnet_ids will be created in aws ssm parameter store 
  type  = "String"
  value = join("," ,module.vpc.private_subnet_ids)      # private_subnet_ids is coming from outputs.tf file  and store in aws ssm parameter store
  overwrite = true           # overwrite = true is used to overwrite the existing value in aws ssm parameter store if it already exists
}

resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project}/${var.environment}/database_subnet_ids"  # /roboshop/dev/database_subnet_ids will be created in aws ssm parameter store 
  type  = "String"
  value = join("," ,module.vpc.database_subnet_ids)      # database_subnet_ids is coming from outputs.tf file  and store in aws ssm parameter store
  overwrite = true           # overwrite = true is used to overwrite the existing value in aws ssm parameter store if it already exists
}

