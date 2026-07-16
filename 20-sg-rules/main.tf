#Mongodb allowing connections form catalogue
resource "aws_security_group_rule" "mongodb_catalogue" {
  type              = "ingress"
  from_port         = 27017     
  to_port           = 27017
  protocol          = "tcp"                         # Destination: The MongoDB database.
  source_security_group_id = local.catalogue_sg_id  # source" means where the traffic is coming from catalogue server 
  security_group_id = local.mongodb_sg_id        # source_security_group_id = Allow incoming traffic only if it originates from 
}                                                # an application/server that has the Catalogue security group attached to it


# MongoDB allowing connections from user on port 27017
resource "aws_security_group_rule" "mongodb_user" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id = local.mongodb_sg_id
}

# MongoDB allowing connections from bastion on port 22
resource "aws_security_group_rule" "mongodb_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.mongodb_sg_id
}

# Redis
resource "aws_security_group_rule" "redis_user" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id = local.redis_sg_id
}

resource "aws_security_group_rule" "redis_cart" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  source_security_group_id = local.cart_sg_id
  security_group_id = local.redis_sg_id
}

resource "aws_security_group_rule" "redis_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.redis_sg_id
}

# MySQL
resource "aws_security_group_rule" "mysql_shipping" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = local.shipping_sg_id
  security_group_id = local.mysql_sg_id
}

resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.mysql_sg_id
}

# RabbitMQ
resource "aws_security_group_rule" "rabbitmq_payment" {
  type              = "ingress"
  from_port         = 5672
  to_port           = 5672
  protocol          = "tcp"
  source_security_group_id = local.payment_sg_id
  security_group_id = local.rabbitmq_sg_id
}

resource "aws_security_group_rule" "rabbitmq_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.rabbitmq_sg_id
}

# Catalogue
resource "aws_security_group_rule" "catalogue_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id = local.catalogue_sg_id
}

resource "aws_security_group_rule" "catalogue_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.catalogue_sg_id
}

# User
resource "aws_security_group_rule" "user_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080    # Who talks to who: ALB ──► User Service EC2 Instance, Port: 8080   
  protocol          = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id = local.user_sg_id
}

resource "aws_security_group_rule" "user_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.user_sg_id
}

# Cart
resource "aws_security_group_rule" "cart_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id = local.cart_sg_id
}

resource "aws_security_group_rule" "cart_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.cart_sg_id
}

# Shipping
resource "aws_security_group_rule" "shipping_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id = local.shipping_sg_id
}

resource "aws_security_group_rule" "shipping_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.shipping_sg_id
}

# Payment
resource "aws_security_group_rule" "payment_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id = local.payment_sg_id
}

resource "aws_security_group_rule" "payment_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.payment_sg_id
}

# Backend ALB, HTTP based
resource "aws_security_group_rule" "backend_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80                         # Who talks to who: End User ──► ALB , Port: 80 or 443
  protocol          = "tcp"
  source_security_group_id = local.frontend_sg_id
  security_group_id = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = local.vpn_sg_id
  security_group_id = local.backend_alb_sg_id
}
resource "aws_security_group_rule" "backend_alb_catalogue" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = local.catalogue_sg_id
  security_group_id = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend_alb_user" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend_alb_cart" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = local.cart_sg_id
  security_group_id = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend_alb_shipping" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = local.shipping_sg_id
  security_group_id = local.backend_alb_sg_id
}

resource "aws_security_group_rule" "backend_alb_payment" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = local.payment_sg_id
  security_group_id = local.backend_alb_sg_id
}

# Frontend
resource "aws_security_group_rule" "frontend_frontend_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = local.frontend_alb_sg_id
  security_group_id = local.frontend_sg_id
}

resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.frontend_sg_id
}

# Frontend ALB
resource "aws_security_group_rule" "frontend_alb_https" {
  type              = "ingress"
  from_port         = 443                     # 443 means secure public web traffic (HTTPS)
  to_port           = 443                     # Whenever you see HTTPS, it always uses port 443 behind the scenes
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]       # accepting all traffic from public 
  security_group_id = local.frontend_alb_sg_id
}

resource "aws_security_group_rule" "frontend_alb_http" {           # http for testing purpose 
  type              = "ingress"
  from_port         = 80                                   
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]                                         #allow traffic from any IP address on the internet
  security_group_id = local.frontend_alb_sg_id
}

# # Bastion
# resource "aws_security_group_rule" "bastion_my_public_ip" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"] # to get my public ip_address    # /32 means single ip_address
#   security_group_id = local.bastion_sg_id
# } 

# Bastion
resource "aws_security_group_rule" "bastion_my_public_ip" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  #cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"] # to get my public ip_address    # /32 means single ip_address
  cidr_blocks = ["73.18.232.81/32"]              # give vpn public ipaddress
  security_group_id = local.bastion_sg_id
} 

# for vpn
resource "aws_security_group_rule" "vpn_public_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # to get my public ip_address    # /32 means single ip_address
  security_group_id = local.vpn_sg_id
} 

# for console
resource "aws_security_group_rule" "vpn_public_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # to get my public ip_address    # /32 means single ip_address
  security_group_id = local.vpn_sg_id
} 

# for console
resource "aws_security_group_rule" "vpn_public_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # to get my public ip_address    # /32 means single ip_address
  security_group_id = local.vpn_sg_id
} 

# 
resource "aws_security_group_rule" "vpn_public_ssh" { # in real TIME we connect ssh to anywhere IP for VPN
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]  # IN REAL TIME WE GIVE LIKE THIS, SO EVERYONE CAN CONNECT TO THIS 
  cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"] # to get my public ip_address    # /32 means single ip_address
  security_group_id = local.vpn_sg_id
} 