resource "aws_vpc" "vpc" {
  cidr_block                       = "10.1.0.0/16"

  tags = {
   Name = "demo-vpc"
 }
}
