terraform {
  required_version = "0.13.5"
  backend "local" {}
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

## VPC
resource "aws_vpc" "test-vpc" {
  cidr_block                       = "10.1.0.0/16"

  tags = {
    Name = "test-vpc"
  }
}

## サブネット東
resource "aws_subnet" "test-sub-east" {
  cidr_block                      = "10.1.1.0/24"
  availability_zone           = "ap-northeast-1a"

  tags = {
    Name = "test-sub-east"
  }

  vpc_id = aws_vpc.test-vpc.id
}

## サブネット西
resource "aws_subnet" "test-sub-west" {
  cidr_block                      = "10.1.2.0/24"
  availability_zone           = "ap-northeast-1c"

  tags = {
    Name = "test-sub-west"
  }

  vpc_id = aws_vpc.test-vpc.id
}

## インターネットゲートウェイ
resource "aws_internet_gateway" "test-gw"{
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

## セキュリティグループ ロードバランサー用
resource "aws_security_group" "test-sg-lb"{
  description = "test-sg-lb"
  name   = "test-sg-lb"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = [var.my-ip]
    from_port   = "80"
    protocol    = "tcp"
    self        = "false"
    to_port     = "80"
  }

  vpc_id = aws_vpc.test-vpc.id
}

## セキュリティグループ サーバ用
resource "aws_security_group" "test-sg-server" {
  description = "test-sg-server"
  name   = "test-sg-server"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = [var.my-ip]
    from_port   = "22"
    protocol    = "tcp"
    self        = "false"
    to_port     = "22"
  }

  ingress {
    from_port       = "80"
    protocol        = "tcp"
    security_groups = [aws_security_group.test-sg-lb.id]
    self            = "false"
    to_port         = "80"
  }

  vpc_id = aws_vpc.test-vpc.id
}

## 鍵
resource "aws_key_pair" "test-key" {
  key_name   = "test-key"
  public_key = file("./test-key.pub")
}

## EC2 1台目
resource "aws_instance" "test-server-east" {
  ami                         = var.ec2-config["ami"]
  associate_public_ip_address = "true"
  availability_zone           = "ap-northeast-1a"

  instance_type           = var.ec2-config["instance-type"]
  key_name                = "test-key"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
  }

  provisioner "remote-exec" {
      connection {
          type = "ssh"
          host = self.public_ip
          user = "ec2-user"
          private_key = file("./test-key")
      }
      inline = ["sudo yum install httpd -y && sudo sh -c \"echo 'Hello East!' >  /var/www/html/index.html\" &&  sudo systemctl start httpd"]
  }

  subnet_id              = aws_subnet.test-sub-east.id
  vpc_security_group_ids = [aws_security_group.test-sg-server.id]
}

## EC2 2台目
resource "aws_instance" "test-server-west" {
  ami                         = var.ec2-config["ami"]
  associate_public_ip_address = "true"
  availability_zone           = "ap-northeast-1c"

  instance_type           = var.ec2-config["instance-type"]
  key_name                = "test-key"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
  }

  provisioner "remote-exec" {
      connection {
          type = "ssh"
          host = self.public_ip
          user = "ec2-user"
          private_key = file("./test-key")
      }
      inline = ["sudo yum install httpd -y && sudo sh -c \"echo 'Hello West!' >  /var/www/html/index.html\" &&  sudo systemctl start httpd"]
  }

  subnet_id              = aws_subnet.test-sub-west.id
  vpc_security_group_ids = [aws_security_group.test-sg-server.id]
}

## ターゲットグループ
resource "aws_lb_target_group" "test-terget" {
  
  health_check {
    enabled             = "true"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "test-target"
  port                          = "80"
  protocol                      = "HTTP"

  target_type = "instance"
  vpc_id      =  aws_vpc.test-vpc.id
}

resource "aws_lb_target_group_attachment" "test-server-east" {
  target_group_arn = aws_lb_target_group.test-terget.arn
  target_id        = aws_instance.test-server-east.id
}   
    
resource "aws_lb_target_group_attachment" "test-server-west" {
  target_group_arn = aws_lb_target_group.test-terget.arn
  target_id        = aws_instance.test-server-west.id
}   

## ロードバランサー
resource "aws_lb_listener" "test-listener" {
  default_action {
    target_group_arn = aws_lb_target_group.test-terget.arn
    type             = "forward"
  }
  
  load_balancer_arn = aws_lb.test-lb.arn
  port              = "80"   
  protocol          = "HTTP" 
}

resource "aws_lb" "test-lb" {
  internal                   = "false"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "test-lb"
  security_groups            = [aws_security_group.test-sg-lb.id]

  subnets = [aws_subnet.test-sub-west.id,aws_subnet.test-sub-east.id]
}

output "alb-domain" {
  value = aws_lb.test-lb.dns_name
}
output "ec2-east-ip" {
  value = aws_instance.test-server-east.public_ip
}
output "ec2-west-ip" {
  value = aws_instance.test-server-west.public_ip
}
