# creating mongodb instance 
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

resource "terraform_data" "mongodb" { # # here we are using terraform data for provisioner only, trigger means when to run.  triggers can control terraform data 
  triggers_replace = [               # If the MongoDB instance doesn't change, running terraform apply 100 times will do absolutely nothing to
    aws_instance.mongodb.id          #  the database or the terraform_data block.Terraform will just say: "No changes. Infrastructure is up-to-date."
  ]         #  triggers_replace = aws_instance.mongodb.id : if any chnage mongodb then triggers work, no changes in mongodb then triggers dont work

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
      "sudo sh /tmp/bootstrap.sh mongodb ${var.environment}" # when we pass mongodb and environment here, they go in bootstrap 15 line(ansible excution)
    ]                                                       # - ansible-playbook -e component=$component -e env=$environment roboshop.yaml
  }
}

# creating mongodb redis 
resource "aws_instance" "redis" {             
  ami           = data.aws_ami.joindevops.id      
  instance_type = "t3.micro"                     
  vpc_security_group_ids = [local.redis_sg_id]  
  subnet_id = local.database_subnet_id
  

  tags = merge(
    {
        Name = "${local.common_name}-redis"
    },
    local.common_tags
  )
}

resource "terraform_data" "redis" { # # here we are using terraform data for provisioner only 
  triggers_replace = [               # trigger means when to run.  also can control terraform data by triggers
    aws_instance.redis.id  #  triggers_replace = aws_instance.redis.id : if any chnage redis then triggers work, no changes in redis then triggers dont work
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        = aws_instance.redis.private_ip  # only private because mongodb will not have public ip address because it is in private subnet
  }

  provisioner "file" { # purpose is to copy local file into remote resource 
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh redis ${var.environment}"   # when we pass redis and environment here, they go in bootstrap 15 line(ansible excution)
    ]                                                        # - ansible-playbook -e component=$component -e env=$environment roboshop.yaml
  }
}