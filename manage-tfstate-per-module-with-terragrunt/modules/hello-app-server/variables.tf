variable "ec2-config" {
  type = object({ ami = string, instance-type = string })
}
variable "vpc-id" {
  type = string
}
variable "subnet-east-id" {
  type = string
}
variable "subnet-west-id" {
  type = string
}
variable "sg-test-lb-id" {
  type = string
}
variable "sg-test-server-id" {
  type = string
}
