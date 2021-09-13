## セキュリティグループ ロードバランサー用
resource "aws_security_group" "test-sg-lb" {
  description = "test-sg-lb"
  name        = "test-sg-lb"

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

  vpc_id = var.vpc-id
}

## セキュリティグループ サーバ用
resource "aws_security_group" "test-sg-server" {
  description = "test-sg-server"
  name        = "test-sg-server"

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

  vpc_id = var.vpc-id
}
