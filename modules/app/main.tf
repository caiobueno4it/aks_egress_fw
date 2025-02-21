resource "null_resource" "aks_app" {
  provisioner "local-exec" {
    command = <<EOT
      # Conectar ao AKS
      az aks get-credentials --resource-group ${var.rg} --name ${var.aks_name} --overwrite-existing

      # Baixar o arquivo YAML do app
      curl -L -o deploy.yaml https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/main/aks-store-quickstart.yaml

      # Aplicar o deployment
      kubectl apply -f deploy.yaml

      # Aguarda até o Service obter um IP (para LoadBalancer)
      kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' svc/store-front -n default --timeout=300s
    EOT
  }
}

# resource "null_resource" "aks_get_svc_ip" {
#   provisioner "local-exec" {
#     command = <<EOT
# export AKS_SVC_IP=$(kubectl get svc store-front -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# EOT
#   }

#   depends_on = [
#     null_resource.aks_app
#   ]
# }


resource "null_resource" "fw_nat_rule" {
  provisioner "local-exec" {
    command = <<EOT
echo $(kubectl get svc store-front -o jsonpath='{.status.loadBalancer.ingress[0].ip}') > aks_svc_ip.txt
AKS_SVC_IP=$(cat aks_svc_ip.txt)
az network firewall nat-rule create \
--collection-name "nat-webapp02" \
--destination-addresses ${var.pip_fw_address} \
--destination-ports 80 \
--firewall-name "${var.fw_name}" \
--name inboundrule \
--protocols Any \
--resource-group "${var.rg}" \
--source-addresses '*' \
--translated-port 80 \
--action Dnat \
--priority 300 \
--translated-address "$AKS_SVC_IP"
EOT
  }

  depends_on = [
    null_resource.aks_app
  ]
}
