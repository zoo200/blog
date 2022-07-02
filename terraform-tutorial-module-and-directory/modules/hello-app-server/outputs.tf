output "alb-domain" {
  value = aws_lb.test-lb.dns_name
}
output "ec2-east-ip" {
  value = aws_instance.test-server-east.public_ip
}
output "ec2-west-ip" {
  value = aws_instance.test-server-west.public_ip
}
