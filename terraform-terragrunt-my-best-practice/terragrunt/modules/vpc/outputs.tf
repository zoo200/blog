output "vpc-demo-id" {
  value = aws_vpc.demo.id
}

output "subnet-demo-ids" {
  value = aws_subnet.demo.*.id
}

output "sg-public-http-id" {
  value = aws_security_group.public-http.id
}

output "sg-container-http-id" {
  value = aws_security_group.container-http.id
}
