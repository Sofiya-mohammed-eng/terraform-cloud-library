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

variable "vpc_id" {
  description = "VPC the database lives in — wire this to the networking category's vpc_id output"
  type        = string
  default     = "REPLACE_WITH_VPC_ID"
}

variable "subnet_ids" {
  description = "At least two subnet IDs, in different AZs, for the DB subnet group"
  type        = list(string)
  default     = ["REPLACE_WITH_SUBNET_ID_A", "REPLACE_WITH_SUBNET_ID_B"]
}

variable "allowed_cidr" {
  description = "CIDR range allowed to reach the database, e.g. the VPC's own range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "taskboard"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "taskboard"
}

variable "db_password" {
  description = "Master password — supply via TF_VAR_db_password, never commit a real value"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

resource "aws_db_subnet_group" "this" {
  name       = "terraform-cloud-library-db"
  subnet_ids = var.subnet_ids

  tags = {
    Project  = "terraform-cloud-library"
    Category = "databases"
  }
}

resource "aws_security_group" "db" {
  name_prefix = "terraform-cloud-library-db-"
  vpc_id      = var.vpc_id

  ingress {
    description = "Postgres from within the network only"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier              = "terraform-cloud-library"
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = var.instance_class
  allocated_storage       = 20
  storage_encrypted       = true
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 7

  tags = {
    Project     = "terraform-cloud-library"
    Category    = "databases"
    Environment = "development"
  }
}

output "endpoint" {
  value = aws_db_instance.this.endpoint
}
