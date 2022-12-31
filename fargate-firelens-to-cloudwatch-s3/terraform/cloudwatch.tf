resource "aws_cloudwatch_log_group" "demo-nginx" {
  name              = "/ecs/demo/nginx"
  retention_in_days = "30"
}

resource "aws_cloudwatch_log_group" "demo-nginx-from-fluent-bit" {
  name              = "/ecs/demo/nginx-from-fluent-bit"
  retention_in_days = "30"
}

resource "aws_cloudwatch_log_group" "demo-fluent-bit" {
  name              = "/ecs/demo/fluent-bit"
  retention_in_days = "30"
}
