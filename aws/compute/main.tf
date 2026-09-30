terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "subnet_id" {
  description = "Subnet to launch the instance into — wire this to an output from the networking category"
  type        = string
  default     = "REPLACE_WITH_SUBNET_ID"
}

variable "vpc_id" {
  description = "VPC the instance's security group belongs to — wire this to an output from the networking category"
  type        = string
  default     = "REPLACE_WITH_VPC_ID"
}

variable "allowed_ssh_cidr" {
  description = "CIDR range allowed to reach the instance over SSH"
  type        = string
  default     = "REPLACE_WITH_YOUR_IP/32"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
}

resource "aws_security_group" "this" {
  name_prefix = "terraform-cloud-library-"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from an allowed range only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-cloud-library-compute-sg"
  }
}

resource "aws_iam_role" "instance" {
  name = "terraform-cloud-library-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "terraform-cloud-library-instance-profile"
  role = aws_iam_role.instance.name
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.debian.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = false

  tags = {
    Name        = "terraform-cloud-library"
    Category    = "compute"
    Environment = "development"
  }
}

output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}
