resource "aws_lb" "frontend_alb" {
  name               = "${local.common_name}-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.frontend_alb_sg_id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    {
        Name = "${local.common_name}-frontend-alb"
    },
    local.common_tags
  )
}


resource "aws_lb_listener" "https" {         # frontend needs https
  load_balancer_arn = aws_lb.frontend_alb.arn  # for which load balnacer listner is creating
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.certificate_arn              # attaching certificate in rules 

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hi, I am from HTTP frontend ALB</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = "${var.project}-${var.environment}.exptrack.shop" # *.exptrack.shop 
  type    = "A"
                                            
  alias {
    # AWS details
    name                   = aws_lb.frontend_alb.dns_name
    zone_id                = aws_lb.frontend_alb.zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}