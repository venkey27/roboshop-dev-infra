# the iam role + trust policy  is creating for ec2 instance
resource "aws_iam_role" "mysql" {
  name = "${local.common_name}-mysql" # roboshop-dev-mysql

  # This is the trust policy, means we can attach this role to EC2 instance
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    {
        Name = "${local.common_name}-mysql"
    },
    local.common_tags
  )
}

#MySQL needs a custom, least-privilege policy, aws_iam_policy "mysql" is the  least-privilege policy
resource "aws_iam_policy" "mysql" {    #It defines the exact permissions (read access to the specific MySQL SSM parameter) from the JSON file
  name        = "${local.common_name}-mysql"
  description = "Policy to read MySQL SSM paramter to attach to mysql instance"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = file("mysql-iam-policy.json")  #file means refer the mysql-iam-policy.json 
}

resource "aws_iam_role_policy_attachment" "mysql" {      # to attacheing policy to  role
  role       = aws_iam_role.mysql.name
  policy_arn = aws_iam_policy.mysql.arn
}

resource "aws_iam_instance_profile" "mysql" {
  name = "${local.common_name}-mysql"
  role = aws_iam_role.mysql.name
}