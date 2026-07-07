resource "aws_instance" "mongodb" {             
  ami           = data.aws_ami.joindevops.id      
  instance_type = "t3.micro"                     
  vpc_security_group_ids = [local.mongodb_sg_id]  
  subnet_id = local.database_subnet_id
  

  tags = merge(
    {
        Name = "${local.common_name}-mongodb"
    },
    local.common_tags
  )
}

# The terraform_data resource does not create any real infrastructure (like an EC2 instance, an S3 bucket, or a database) on AWS or any other cloud. It is a completely "empty" resource.

# Its main purpose is to act as a placeholder or trigger provisioners or to run local commands, run scripts, or manage lifecycle behaviors.

resource "terraform_data" "mongodb" {
  triggers_replace = [               # trigger means when to run.  also can control terraform data by triggers
    aws_instance.mongodb.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        = aws_instance.mongodb.private_ip  # only private because mongodb will not have public ip address because it is in private subnet
  }

  provisioner "file" { # purpose is to copy local file into remote resource 
    source      = "bootstrap.sh" 
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mongodb ${var.environment}"
    ]
  }
}