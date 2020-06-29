resource "null_resource" "helm_install_nginx" {
  depends_on = [
    module.eks,
    null_resource.kubectl_update
  ]
  provisioner "local-exec" {
    command = <<EOF
      helm repo add bitnami https://charts.bitnami.com/bitnami
      helm repo update
      helm install nginx bitnami/nginx
    EOF
    environment = {
      AWS_REGION = var.region
      NAME = local.project
    }
  }
}

resource "null_resource" "helm_install_metrics_server" {
  depends_on = [
    module.eks,
    null_resource.kubectl_update
  ]
  provisioner "local-exec" {
    command = <<EOF
      helm repo add stable https://kubernetes-charts.storage.googleapis.com
      helm repo update
      helm install metrics stable/metrics-server
    EOF
    environment = {
      AWS_REGION = var.region
      NAME = local.project
    }
  }
}

# https://www.eksworkshop.com/intermediate/240_monitoring/deploy-prometheus/

resource "null_resource" "helm_install_grafana" {
  depends_on = [
    module.eks,
    null_resource.kubectl_update
  ]
  provisioner "local-exec" {
    command = <<EOF
kubectl create namespace prometheus
helm install prometheus stable/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"

kubectl create namespace grafana
helm install grafana stable/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='EKS!sAWSome' \
    --values helm_charts/grafana.yaml \
    --set service.type=LoadBalancer
    EOF
    environment = {
      AWS_REGION = var.region
      NAME = local.project
    }
  }
}

output "grafana" {
  value = <<EOF
echo "Get the grafana ELB URL"
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "http://$ELB"
echo "Get the login password. Login as admin and this password"
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
EOF
}

output "helm-cleanup" {
  value = <<EOF
If you wish to clean up your helm charts run the following:
helm uninstall prometheus --namespace prometheus
helm uninstall grafana --namespace grafana
helm delete nginx
helm delete metrics
EOF
}

output "kubernetes_dashboard" {
  value = <<EOF
To install the Grafana Dashboard
Click ’+’ button on left panel and select ‘Import’.
Enter 3119 dashboard id under Grafana.com Dashboard.
Click ‘Load’.
Select ‘Prometheus’ as the endpoint under prometheus data sources drop down.
Click ‘Import’.
EOF
}
