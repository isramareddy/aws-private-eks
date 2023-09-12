variable "aws_region" {
  description = "The AWS region where the resources will be created."
  default     = "ap-south-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  default     = "10.0.1.0/24"
}

variable "private_subnet_az1_cidr" {
  description = "CIDR block for the private subnet in availability zone 1."
  default     = "10.0.2.0/24"
}

variable "private_subnet_az2_cidr" {
  description = "CIDR block for the private subnet in availability zone 2."
  default     = "10.0.3.0/24"
}

variable "bastion_instance_ami" {
  description = "The AMI ID for the Bastion Server instance."
  default     = "ami-0700df939e7249d03"
}

variable "bastion_instance_type" {
  description = "The instance type for the Bastion Server."
  default     = "t2.micro"
}

variable "bastion_key_name" {
  description = "The name of the key pair to use for the Bastion Server."
  default     = "new_key"
}
