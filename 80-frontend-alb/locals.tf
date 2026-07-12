locals {
    common_name = "${var.project}-${var.environment}"
    frontend_alb_sg_id = data.aws_ssm_parameter.frontend_alb_sg_id.value
    public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)      # split create List(String)
    certificate_arn = data.aws_ssm_parameter.certificate_arn.value
    common_tags = {
        Project = "${var.project}"
        Environment = "${var.environment}"
        Terraform = "true"
    }
}

# this is how the split function works here private_subnet_ids
#    [
#   "subnet-01234567",
#   "subnet-89abcdef",
#   "subnet-xyz12345"
# ]