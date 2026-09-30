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

variable "bucket_arn" {
  description = "ARN of the bucket to grant read access to — wire this to the storage category's bucket_arn output"
  type        = string
  default     = "REPLACE_WITH_BUCKET_ARN"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bucket_reader" {
  name               = "terraform-cloud-library-bucket-reader"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Project  = "terraform-cloud-library"
    Category = "iam"
  }
}

data "aws_iam_policy_document" "bucket_read" {
  statement {
    sid     = "ListSingleBucket"
    actions = ["s3:ListBucket"]
    resources = [
      var.bucket_arn,
    ]
  }

  statement {
    sid     = "ReadSingleBucketObjects"
    actions = ["s3:GetObject"]
    resources = [
      "${var.bucket_arn}/*",
    ]
  }
}

resource "aws_iam_policy" "bucket_read" {
  name   = "terraform-cloud-library-bucket-read"
  policy = data.aws_iam_policy_document.bucket_read.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.bucket_reader.name
  policy_arn = aws_iam_policy.bucket_read.arn
}

output "role_arn" {
  value = aws_iam_role.bucket_reader.arn
}

output "policy_arn" {
  value = aws_iam_policy.bucket_read.arn
}
