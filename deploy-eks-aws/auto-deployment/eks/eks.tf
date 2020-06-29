########################################################################
# EKS Cluster
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/12.1.0
########################################################################

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "12.1.0"
  cluster_name = local.project
  cluster_version = "1.16"
  subnets = module.vpc.private_subnets

  tags = {
    Name = local.project
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name = "${local.project}-worker-group-t2-medium"
      instance_type = "t2.medium"
      additional_security_group_ids = [
        aws_security_group.all_worker_mgmt_ssh.id
      ]
      asg_desired_capacity = 1
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
