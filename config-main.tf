provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "test-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                 = aws_vpc.test-vpc.id
  cidr_block             = var.public_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true
  availability_zone      = var.public_subnet_availability_zones[count.index]

  tags = {
    Name                              = "${var.vpc_name}-public-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/ed-eks-01" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id             = aws_vpc.test-vpc.id
  cidr_block         = var.private_subnet_cidr_blocks[count.index]
  availability_zone  = var.private_subnet_availability_zones[count.index]

  tags = {
    Name                              = "${var.vpc_name}-private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/ed-eks-01" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_eip" "nat_eip" {
  count = length(var.private_subnet_availability_zones)

  vpc = true

  tags = {
    Name = "${var.vpc_name}-nat-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.private_subnet_availability_zones)

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index % length(aws_subnet.public_subnet)].id

  tags = {
    Name = "${var.vpc_name}-nat-gateway-${count.index}"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-route"
  }
}

resource "aws_route_table" "private_route" {
  count = length(var.private_subnet_availability_zones)

  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "${var.vpc_name}-private-route-${count.index}"
  }
}

resource "aws_route_table_association" "public_association" {
  count = length(aws_subnet.public_subnet)

  subnet_id     = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private_association" {
  count = length(aws_subnet.private_subnet)

  subnet_id     = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route[count.index].id
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

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
  ami           = var.bastion_ami
  instance_type = var.bastion_instance_type
  key_name      = var.bastion_key_name
  subnet_id     = aws_subnet.public_subnet[0].id
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "${var.vpc_name}-BastionServer"
  }
}
