output "sg-test-lb-id" {
  value = aws_security_group.test-sg-lb.id
}

output "sg-test-server-id" {
  value = aws_security_group.test-sg-server.id
}
