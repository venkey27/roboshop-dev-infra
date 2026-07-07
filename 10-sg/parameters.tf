resource "aws_ssm_parameter" "vpc_id" {
  count = length(var.sg_names)
  name  = "/${var.project}/${var.environment}/${var.sg_names[count.index]}_sg_id"  # /roboshop/dev/vpc_id will be created in aws ssm parameter store 
  type  = "String"
  value = module.sg[count.index].sg_id         # sg_id is coming from .terraform/outputs.tf file and store in aws ssm parameter store
  overwrite = true           # overwrite = true is used to overwrite the existing value in aws ssm parameter store if it already exists
}

 # value = module.<MODULE_NAME>.<OUTPUT_NAME>