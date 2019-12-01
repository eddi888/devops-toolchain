
resource "aws_key_pair" "admin" {
  key_name   = "admin"
  public_key = var.public_admin_key
}

resource "aws_security_group" "public_http_in" {
  name        = "public_http_in"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "http_in" {
  name        = "http_in"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.office_cidr_blocks
  }
}

resource "aws_security_group" "public_https_in" {
  name        = "public_https_in"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https_in" {
  name        = "https_in"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.office_cidr_blocks
  }
}

resource "aws_security_group" "tomcat_in" {
  name        = "tomcat_in"
  description = "Allow 8080 inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.office_cidr_blocks
  }
}

resource "aws_security_group" "nexus_in" {
  name        = "nexus_in"
  description = "Allow 8081 inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = var.office_cidr_blocks
  }
}

resource "aws_security_group" "ssh_in" {
  name        = "ssh_in"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.office_cidr_blocks
  }
}

resource "aws_security_group" "dns_in" {
  name        = "dns_in"
  description = "Allow DNS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = var.office_cidr_blocks
  }
}

resource "aws_security_group" "ping_in" {
  name        = "ping_in"
  description = "Allow Ping inbound traffic"
  vpc_id      = aws_vpc.main.id
  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = var.office_cidr_blocks
    description = "Allow ping"
  }
}

resource "aws_security_group" "all_out" {
  name        = "all_out"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "DevOps Toolchain"
    Team = "DevOps Toolchain"
  }
}