data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project}/${var.environment}/vpc_id"
}

# used to fetch an existing VPC ID that was previously saved in AWS Systems Manager (SSM) Parameter Store.