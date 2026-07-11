resource "aws_ssm_parameter" "backend_alb_listener_arn" { #storing the Listener ARN in the Parameter Store.
  name  = "/${var.project}/${var.environment}/backend_alb_listener_arn"
  type  = "String"
  value = aws_lb_listener.http.arn
  overwrite = true
}