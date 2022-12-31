## VPC
resource "aws_vpc" "demo" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = "demo"
  }
}

## サブネット
resource "aws_subnet" "demo" {
  vpc_id = aws_vpc.demo.id

  count = length(var.subnets)

  cidr_block        = lookup(var.subnets[count.index], "cidr")
  availability_zone = lookup(var.subnets[count.index], "az")

  tags = {
    Name = "demo-${count.index + 1}"
  }
}

## インターネットゲートウェイ
resource "aws_internet_gateway" "demo" {
  tags = {
    Name = "demo"
  }

  vpc_id = aws_vpc.demo.id
}

## ルートテーブル
resource "aws_route_table" "demo" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }

  tags = {
    Name = "demo"
  }

  vpc_id = aws_vpc.demo.id
}

resource "aws_route_table_association" "demo" {
  count          = length(aws_subnet.demo)
  subnet_id      = lookup(aws_subnet.demo[count.index], "id")
  route_table_id = aws_route_table.demo.id
}
