## 公開用HTTP
resource "aws_security_group" "public-http" {
  description = "public-http"
  name        = "public-http"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    protocol    = "tcp"
    self        = "false"
    to_port     = "80"
  }

  tags = {
    Name = "public-http"
  }
  vpc_id = aws_vpc.demo.id
}

## コンテナ用HTTP 
resource "aws_security_group" "container-http" {
  description = "container-http"
  name        = "container-http"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    from_port       = "80"
    protocol        = "tcp"
    self            = "false"
    security_groups = [aws_security_group.public-http.id]
    to_port         = "80"
  }

  tags = {
    Name = "container-http"
  }
  vpc_id = aws_vpc.demo.id
}

