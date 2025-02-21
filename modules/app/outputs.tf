# # Obter Service IP no AKS
# output "aks_service_ip" {
#   # value = null_resource.aks_read_service_ip
#   value = trimspace(join("", [for line in split("\n", file("./aks_service_ip.txt")) : line]))
#   depends_on = [
#     null_resource.aks_get_service_ip
#   ]
# }