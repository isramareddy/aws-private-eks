provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "vpc2" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "publicsubnetvpc" {
  vpc_id                  = aws_vpc.vpc.id
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

resource "aws_subnet" "privatesubnetvpc_az1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_az1_cidr
  availability_zone = "ap-south-1b"

  tags = {
    Name                              = "privatevpc_az1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/ed-eks-01" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}

resource "aws_subnet" "privatesubnetvpc_az2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_az2_cidr
  availability_zone = "ap-south-1c"

  tags = {
    Name                              = "privatevpc_az2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/ed-eks-01" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}

resource "aws_internet_gateway" "igwvpc" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vpcigw"
  }
}

resource "aws_eip" "eipvpc" {
  vpc = true

  tags = {
    Name = "eipvpc"
  }
}

resource "aws_nat_gateway" "nat-gwvpc" {
  allocation_id = aws_eip.eipvpc.id
  subnet_id     = aws_subnet.publicsubnetvpc.id

  tags = {
    Name = "igwNATvpc"
  }
}

resource "aws_route_table" "publicroutevpc" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igwvpc.id
  }

  tags = {
    Name = "publicroutevpc"
  }
}

resource "aws_route_table" "privateroutevpc" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gwvpc.id
  }

  tags = {
    Name = "privateroutevpc"
  }
}

resource "aws_route_table_association" "public-associationvpc" {
  subnet_id      = aws_subnet.publicsubnetvpc.id
  route_table_id = aws_route_table.publicroutevpc.id
}

resource "aws_route_table_association" "private-associationvpc_az1" {
  subnet_id      = aws_subnet.privatesubnetvpc_az1.id
  route_table_id = aws_route_table.privateroutevpc.id
}

resource "aws_route_table_association" "private-associationvpc_az2" {
  subnet_id      = aws_subnet.privatesubnetvpc_az2.id
  route_table_id = aws_route_table.privateroutevpc.id
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.vpc.id

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
  subnet_id     = aws_subnet.publicsubnetvpc.id
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionServer"
  }
}
