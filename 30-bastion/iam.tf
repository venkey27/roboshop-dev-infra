resource "aws_iam_role" "bastion" {      #creating iam role for bastion
  name = "${local.common_name}-bastion"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"                   # this policy is for ec2 access
        }
      },
    ]
  })

  tags = merge (
        local.common_tags,
        {
             Name = "${local.common_name}-bastion"
        }
    )
  
}

resource "aws_iam_role_policy_attachment" "bastion" {              # assiging administrator access for the cretaed bastion IAM role
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create the IAM Instance Profile
resource "aws_iam_instance_profile" "bastion" {    # purpose is chnage the iam role for the instance - 
  name = "${local.common_name}-bastion"     # - we manullay change iam role in action --> security --> modify IAM role for this aws_iam_instance_profile
  role = aws_iam_role.bastion.name
}