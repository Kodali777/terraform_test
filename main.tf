provider "aws" {
  region     = "ap-south-1"
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "myVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "myVPC-vpc"
  }
}

resource "aws_subnet" "pubsubnet" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pubsubnet-subnet-a"
  }
}

resource "aws_subnet" "pvtsubnet" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pvtsubnet-subnet-b"
  }
}

resource "aws_internet_gateway" "myIGw" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = "myIGw-igw"
  }
}

resource "aws_route_table" "myRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGw.id
  }

  tags = {
    Name = "myRT-route-table"
  }
}

resource "aws_route_table_association" "myRTa_a" {
  subnet_id      = aws_subnet.pubsubnet.id
  route_table_id = aws_route_table.myRT.id
}

resource "aws_route_table_association" "myRTa_b" {
  subnet_id      = aws_subnet.pvtsubnet.id
  route_table_id = aws_route_table.myRT.id
}

resource "aws_instance" "myVM" {
  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  key_name      = "ap-south-1keypair"
  subnet_id     = aws_subnet.pubsubnet.id
  tags = {
    Name = "myVM"
  }
}
