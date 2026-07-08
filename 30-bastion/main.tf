resource "aws_instance" "bastion" {              #A Bastion host (also called a Jump Server) is a special server used by developers and 
  ami           = data.aws_ami.joindevops.id     #DevOps engineers to securely log into private database servers or backend apps. 
  instance_type = "t3.micro"                     # Because it sits on the public internet, it is a high-risk target.
  vpc_security_group_ids = [local.bastion_sg_id]  # is used to attach the specific Bastion firewall rules (security group) to this EC2 instance.
  subnet_id = local.public_subnet_id
  iam_instance_profile = aws_iam_instance_profile.bastion.name # attaching an IAM role to an EC2 instance

  # we will only get user_data option at the  creation of instance only. once instance got created we can change user data
  user_data = templatefile("${path.module}/bastion.sh.tftpl", {    # path.module=present location # tftp = terraform template
    partition_number = 4                                       
    extend_size = 30                           # this partition_number and extend_size are used in bastion.sh.tftpl
  })
  root_block_device {               # 20 GiB not enough so we are upgrading to 50 GiB
    volume_size           = 50      # Size of the volume in GiB        
    volume_type           = "gp3"   # General Purpose SSD (gp3 is recommended)

    tags = merge(
        {
            Name = "${local.common_name}-bastion"
        },
        local.common_tags
    )
  }

  tags = merge(
    {
        Name = "${local.common_name}-bastion"
    },
    local.common_tags
  )
}