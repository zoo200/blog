output "vpc-id" {
  value = aws_vpc.test-vpc.id
}
output "subnet-east-id" {
  value = aws_subnet.test-sub-east.id
}
output "subnet-west-id" {
  value = aws_subnet.test-sub-west.id
}
