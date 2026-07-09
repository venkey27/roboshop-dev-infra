locals {
    common_name = "${var.project}-${var.environment}"
    backend_alb_sg_id = data.aws_ssm_parameter.backend_alb_sg_id.value
    private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)      # split create List(String)
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