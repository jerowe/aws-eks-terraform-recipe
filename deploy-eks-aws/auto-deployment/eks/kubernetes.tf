########################################################################
# Kubernetes Provider
# This allows us to execute commands on a particular kubernetes cluster
# We use this later with the secrets
########################################################################

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
  version = "~> 1.11"
}


########################################################################
# Update the ~/.kube/config
########################################################################

resource "null_resource" "kubectl_update" {
  depends_on = [
    module.eks,
  ]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "aws eks --region $AWS_REGION update-kubeconfig --name $NAME"
    environment = {
      AWS_REGION = var.region
      NAME = local.project
    }
  }
}
