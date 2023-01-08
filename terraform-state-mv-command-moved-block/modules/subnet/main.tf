resource "aws_subnet" "demo" {
  vpc_id     = var.vpc-id
  cidr_block = "10.1.0.0/24"

  tags = {
    Name = "demo"
  }
}
