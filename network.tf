
resource "aws_vpc" "main" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "DevOps Toolchain"
    Team = "DevOps Toolchain"
  }
}

resource "aws_vpc_dhcp_options" "dn" {
  domain_name         = var.domain_name
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    Name = "DevOps Toolchain"
    Team = "DevOps Toolchain"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.dn.id
}


resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.16.1.0/24"
  tags = {
    Name = "DevOps Toolchain"
    Team = "DevOps Toolchain"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.16.2.0/24"
  tags = {
    Name = "DevOps Toolchain"
    Team = "DevOps Toolchain"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "DevOps Toolchain"
    Team = "DevOps Toolchain"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "DevOps Toolchain"
    Team = "DevOps Toolchain"
  }
}

resource "aws_main_route_table_association" "rta" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.rt.id
}

# fixed public stable IP for HTTPS-Endpoint
resource "aws_eip" "httpd" {
  instance = aws_instance.httpd.id
  tags = {
    Name = "Fixed DevOps IP"
    Team = "DevOps Toolchain"
  }
}


