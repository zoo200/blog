## VPC
resource "aws_vpc" "test-vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "test-vpc"
  }
}

## サブネット東
resource "aws_subnet" "test-sub-east" {
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "test-sub-east"
  }

  vpc_id = aws_vpc.test-vpc.id
}

## サブネット西
resource "aws_subnet" "test-sub-west" {
  cidr_block        = "10.1.2.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "test-sub-west"
  }

  vpc_id = aws_vpc.test-vpc.id
}

## インターネットゲートウェイ
resource "aws_internet_gateway" "test-gw" {
  tags = {
    Name = "test-gw"
  }

  vpc_id = aws_vpc.test-vpc.id
}

## ルートテーブル
resource "aws_route_table" "test-route" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-gw.id
  }

  tags = {
    Name = "test-route"
  }

  vpc_id = aws_vpc.test-vpc.id
}

resource "aws_route_table_association" "sub-east" {
  route_table_id = aws_route_table.test-route.id
  subnet_id      = aws_subnet.test-sub-east.id
}

resource "aws_route_table_association" "sub-west" {
  route_table_id = aws_route_table.test-route.id
  subnet_id      = aws_subnet.test-sub-west.id
}
