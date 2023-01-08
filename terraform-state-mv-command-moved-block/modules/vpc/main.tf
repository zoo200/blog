resource "aws_vpc" "demo" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "demo"
  }
}

## リファクタリングのタイミングで削除
resource "aws_subnet" "demo" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = "10.1.0.0/24"

  tags = {
    Name = "demo"
  }
}

