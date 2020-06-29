variable "prefix" {
  type = string
  default = "eks-cluster"
}

resource "random_string" "prefix" {
  upper = false
  special = false
  lower = true
  length = 16
}

output "prefix" {
  description = "Project Prefix"
  value = var.prefix
}

locals {
  project = "${var.prefix}-${random_string.prefix.result}"
}

output "project" {
  description = "Project name - all resources are prefixed with this project name"
  value = local.project
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value = local.project
}

