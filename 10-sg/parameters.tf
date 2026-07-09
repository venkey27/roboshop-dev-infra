resource "aws_ssm_parameter" "vpc_id" {
  count = length(var.sg_names)
  name  = "/${var.project}/${var.environment}/${var.sg_names[count.index]}_sg_id"  # /roboshop/dev/backend_alb_sg_id will be created in aws ssm parameter store 
  type  = "String"
  value = module.sg[count.index].sg_id         # sg_id is coming from .terraform/outputs.tf file and store in aws ssm parameter store
  overwrite = true           # overwrite = true is used to overwrite the existing value in aws ssm parameter store if it already exists
}

 # value = module.<MODULE_NAME>.<OUTPUT_NAME>
 # .sg_id is used to export the real AWS ID out of the module so that your root code can output it to your terminal, save it to a state file,
  # or pass it over to AWS SSM Parameter store for your other resources to use.