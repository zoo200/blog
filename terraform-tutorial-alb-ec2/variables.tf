variable "my-ip" {
  type    = string
  default = "11.22.33.44/32"
}

variable "ec2-config" {
  type    = object({ ami = string, instance-type = string })
  default = { ami = "ami-034968955444c1fd9", instance-type = "t2.micro" }
}


