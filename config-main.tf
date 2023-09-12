provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "vpc2" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc2"
  }
}

resource "aws_subnet" "publicsubnetvpc2" {
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name                              = "publicvpc2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/ed-eks-01" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}

resource "aws_subnet" "privatesubnetvpc2_az1" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = var.private_subnet_az1_cidr
  availability_zone = "ap-south-1b"

  tags = {
    Name                              = "privatevpc2_az1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/ed-eks-01" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}

resource "aws_subnet" "privatesubnetvpc2_az2" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = var.private_subnet_az2_cidr
  availability_zone = "ap-south-1c"

  tags = {
    Name                              = "privatevpc2_az2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/ed-eks-01" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}

resource "aws_internet_gateway" "igwvpc2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "vpc2igw"
  }
}

resource "aws_eip" "eipvpc2" {
  vpc = true

  tags = {
    Name = "eipvpc2"
  }
}

resource "aws_nat_gateway" "nat-gwvpc2" {
  allocation_id = aws_eip.eipvpc2.id
  subnet_id     = aws_subnet.publicsubnetvpc2.id

  tags = {
    Name = "igwNATvpc2"
  }
}

resource "aws_route_table" "publicroutevpc2" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igwvpc2.id
  }

  tags = {
    Name = "publicroutevpc2"
  }
}

resource "aws_route_table" "privateroutevpc2" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gwvpc2.id
  }

  tags = {
    Name = "privateroutevpc2"
  }
}

resource "aws_route_table_association" "public-associationvpc2" {
  subnet_id      = aws_subnet.publicsubnetvpc2.id
  route_table_id = aws_route_table.publicroutevpc2.id
}

resource "aws_route_table_association" "private-associationvpc2_az1" {
  subnet_id      = aws_subnet.privatesubnetvpc2_az1.id
  route_table_id = aws_route_table.privateroutevpc2.id
}

resource "aws_route_table_association" "private-associationvpc2_az2" {
  subnet_id      = aws_subnet.privatesubnetvpc2_az2.id
  route_table_id = aws_route_table.privateroutevpc2.id
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.vpc2.id

  ingress {
    description = "ssh access to public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http access to public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https access to public"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "jump_server" {
  ami           = var.bastion_instance_ami
  instance_type = var.bastion_instance_type
  key_name      = var.bastion_key_name
  subnet_id     = aws_subnet.publicsubnetvpc2.id
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionServer"
  }
}
