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

# Control the running state explicitly
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"                          # Allowed values: "running" or "stopped" , state =  we can stop or run the instance state 
  depends_on = [ terraform_data.catalogue ]            # means when terraform_data" "catalogue" configuration is done, 
                                               #  then after "aws_ec2_instance_state" "catalogue" configuration will run and stop the instaance 
}

# resource allows the creation of an Amazon Machine Image (AMI)              # AMI brings The Operating System (e.g., Linux, Windows
resource "aws_ami_from_instance" "catalogue" {                               # Your code, installed software, and system files
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

# resource allows the creation of an lunch template
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

# resource allows the creation of an Target group
resource "aws_lb_target_group" "catalogue" {  # target consist of instances 
  name     = "${local.common_name}-catalogue"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 30       # If there are users already connected to that server, the Load Balancer gives them exactly 30 seconds 
                                  # to finish what they are doing (completing their download, saving their data, etc.).

  health_check {               # {} means here block # target group consist of health check 
    healthy_threshold = 2
    interval = 10               # every 10 seconds health check will done
    matcher = "200-299"
    path = "/health"           
    port = 8080
    protocol = "HTTP"
    timeout = 5                 # response should come in 5 seconds
    unhealthy_threshold = 2     #  2 consecutive  health check fails then instance is not in good condition
  }
}

# resource allows the creation of an autoscaling
resource "aws_autoscaling_group" "catalogue" {
  name                      = "${local.common_name}-catalogue"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 120                     # 120 = 2 min, do the health check after 2 minutes of instances got created 
  health_check_type         = "ELB"                   # load balancer will do health check
  desired_capacity          = 2
  force_delete              = false                   # after delation of instances then auto-sacling will have to delete 

  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }

  vpc_zone_identifier       = [local.private_subnet_id]

  target_group_arns = [aws_lb_target_group.catalogue.arn] # Autoscaling launches into specific target group

  # instance_refresh {
  #   strategy = "Rolling"
  #   preferences {
  #     min_healthy_percentage = 50
  #   }
  #   triggers = ["launch_template"]
  # }

  dynamic "tag" {
    for_each = merge(
      {
        Name = "${local.common_name}-catalogue"
      },
      local.common_tags
    )
    content{
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # with in 15min autoscaling should be successful to launch instances
  timeouts {
    delete = "15m"
  }
}

# auto-scaling policy creation for average cpu utilization 
resource "aws_autoscaling_policy" "catalogue" {
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  name                   = "${local.common_name}-catalogue"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 120
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}