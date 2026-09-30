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

variable "instance_id" {
  description = "EC2 instance to monitor — wire to the compute category's instance_id output"
  type        = string
  default     = "REPLACE_WITH_INSTANCE_ID"
}

variable "alert_email" {
  description = "Email address to notify on alarm"
  type        = string
  default     = "REPLACE_WITH_YOUR_EMAIL"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/terraform-cloud-library/app"
  retention_in_days = 30

  tags = {
    Project  = "terraform-cloud-library"
    Category = "monitoring"
  }
}

resource "aws_sns_topic" "alerts" {
  name = "terraform-cloud-library-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "terraform-cloud-library-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU above 80% for 10 minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = var.instance_id
  }
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
