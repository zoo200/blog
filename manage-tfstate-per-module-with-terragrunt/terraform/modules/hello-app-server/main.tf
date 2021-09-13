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

  instance_type = var.ec2-config["instance-type"]
  key_name      = "test-key"

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("./test-key")
    }
    inline = ["sudo yum install httpd -y && sudo sh -c \"echo 'Hello East!' >  /var/www/html/index.html\" &&  sudo systemctl start httpd"]
  }

  subnet_id              = var.subnet-east-id
  vpc_security_group_ids = [var.sg-test-server-id]

  tags = {
    Name = "test-server-east"
  }
}

## EC2 2台目
resource "aws_instance" "test-server-west" {
  ami                         = var.ec2-config["ami"]
  associate_public_ip_address = "true"
  availability_zone           = "ap-northeast-1c"

  instance_type = var.ec2-config["instance-type"]
  key_name      = "test-key"

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("./test-key")
    }
    inline = ["sudo yum install httpd -y && sudo sh -c \"echo 'Hello West!' >  /var/www/html/index.html\" &&  sudo systemctl start httpd"]
  }

  subnet_id              = var.subnet-west-id
  vpc_security_group_ids = [var.sg-test-server-id]

  tags = {
    Name = "test-server-west"
  }
}

## ターゲットグループ
resource "aws_lb_target_group" "test-terget" {

  health_check {
    enabled  = "true"
    matcher  = "200"
    path     = "/"
    port     = "traffic-port"
    protocol = "HTTP"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "test-target"
  port                          = "80"
  protocol                      = "HTTP"

  target_type = "instance"
  vpc_id      = var.vpc-id
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
  internal           = "false"
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  name               = "test-lb"
  security_groups    = [var.sg-test-lb-id]

  subnets = [var.subnet-east-id, var.subnet-west-id]
}
