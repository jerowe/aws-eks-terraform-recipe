terraform {
  required_version = ">= 0.12.0"
}

variable "region" {
  default = "us-east-1"
}

provider "aws" {
  version = ">= 2.28.1"
  region = var.region
}

data "aws_availability_zones" "available" {
}

provider "null" {
  version = "~> 2.1"
}

