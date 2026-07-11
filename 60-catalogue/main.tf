# creating mongodb catalogue
resource "aws_instance" "catalogue" {             
  ami           = local.ami_id  
  instance_type = "t3.micro"                     
  vpc_security_group_ids = [local.catalogue_sg_id]  
  subnet_id = local.private_subnet_id
  

  tags = merge(
    {
        Name = "${local.common_name}-catalogue"
    },
    local.common_tags
  )
}


resource "terraform_data" "catalogue" {          # here we are using terraform data for provisioner only 
  triggers_replace = [                           # trigger means when to run.  also can control terraform data by triggers
    aws_instance.catalogue.id                    #  triggers_replace = aws_instance.redis.id : if any chnage in redis instance then triggers work, 
  ]                                                                         #no changes in redis instance then triggers dont work

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        = aws_instance.catalogue.private_ip  # only private because mongodb will not have public ip address because it is in private subnet
  }

  provisioner "file" {                               # purpose is to copy local file into remote resource 
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue ${var.environment} ${var.app_version}"   # when we pass redis and environment here, 
    ]               # they go in bootstrap 15 line(ansible excution)     # - ansible-playbook -e component=$component -e env=$environment roboshop.yaml
  }
}

# 2. Control the running state explicitly
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped" # Allowed values: "running" or "stopped" , state =  we can stop or run the instance state 
  depends_on = [ terraform_data.catalogue ]            # means when terraform_data" "catalogue" configuration is done, 
                                               #  then after "aws_ec2_instance_state" "catalogue" configuration will run and stop the instaance 
}

# resource allows the creation of an Amazon Machine Image (AMI)
resource "aws_ami_from_instance" "catalogue" {
  name               = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"  # roboshop-dev-catalogue-v3-instance-id
  source_instance_id = aws_instance.catalogue.id
  depends_on = [ aws_ec2_instance_state.catalogue ]                # means when "aws_ec2_instance_state" "catalogue" INSTANCE STOPS completely , 
                                                         # then after "aws_ami_from_instance" "catalogue" configuration will run and creates AMI

  tags = merge(
    {
        Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
    },
    local.common_tags
  )
}

resource "aws_launch_template" "catalogue" {
  name = "${local.common_name}-catalogue"    # form catalogue ami id

  image_id = aws_ami_from_instance.catalogue.id

  instance_initiated_shutdown_behavior = "terminate"  # we get 2 options stop or terminate, we dont use stop because we have to pay extra money

  instance_type = "t3.micro"

  vpc_security_group_ids = [local.catalogue_sg_id]

  update_default_version = true  # if lunch template is updated then take eww template by defult  

   # Once the instances are created, these will become instance tags
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
          Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
      },
      local.common_tags
    )
  }

  # Once the instances are created, these will become volume tags
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
          Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
      },
      local.common_tags
    )
  }

  
}