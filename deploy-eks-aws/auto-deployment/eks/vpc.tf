########################################################################
# VPC
# Our kubernetes cluster will sit in its own VPC
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/2.21.0
########################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = local.project
  cidr = "10.0.0.0/16"
  azs = data.aws_availability_zones.available.names
  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"]
  public_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.project}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.project}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
