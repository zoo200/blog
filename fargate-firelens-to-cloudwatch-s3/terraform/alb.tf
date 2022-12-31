resource "aws_lb" "demo" {
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "demo"
  security_groups    = [aws_security_group.public-http.id]

  subnets = aws_subnet.demo.*.id
}

resource "aws_lb_target_group" "demo" {

  health_check {
    enabled  = "true"
    matcher  = "200"
    path     = "/"
    port     = "traffic-port"
    protocol = "HTTP"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "demo"
  port                          = var.port["http"]
  protocol                      = "HTTP"

  target_type = "ip"
  vpc_id      = aws_vpc.demo.id
}

resource "aws_lb_listener" "demo" {

  default_action {
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }

    order = "1"
    type  = "fixed-response"
  }

  load_balancer_arn = aws_lb.demo.id
  port              = var.port["http"]
  protocol          = "HTTP"
}

resource "aws_lb_listener_rule" "ecs" {
  action {
    order            = "1"
    target_group_arn = aws_lb_target_group.demo.arn
    type             = "forward"
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  listener_arn = aws_lb_listener.demo.arn
  priority     = "10"
}
