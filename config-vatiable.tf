variable "aws_region" {
  description = "AWS region where resources will be created."
  default     = "ap-south-1"
}

#variable "vpc_cidr_block" {
#  description = "CIDR block for the VPC."
#  default     = "10.0.0.0/16"
#}

variable "vpc_name" {
  description = "Name for the VPC."
  default     = "test-vpc"
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for public subnets."
  default     = ["10.0.1.0/24"]
}

variable "public_subnet_availability_zones" {
  description = "List of availability zones for public subnets."
  default     = ["ap-south-1a"]
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets."
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "private_subnet_availability_zones" {
  description = "List of availability zones for private subnets."
  default     = ["ap-south-1b", "ap-south-1c"]
}

variable "bastion_ami" {
  description = "AMI ID for the Bastion Server."
  default     = "ami-0ff30663ed13c2290"
}

variable "bastion_instance_type" {
  description = "Instance type for the Bastion Server."
  default     = "t2.micro"
}

variable "bastion_key_name" {
  description = "Name of the key pair for the Bastion Server."
  default     = "new_key"
}
