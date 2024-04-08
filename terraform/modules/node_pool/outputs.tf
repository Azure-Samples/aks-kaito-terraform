output "name" {
  description = "Specifies the name of the node pool"
  value       = azurerm_kubernetes_cluster_node_pool.node_pool.name
}

output "id" {
  description = "Specifies the resource id of the node pool"
  value       = azurerm_kubernetes_cluster_node_pool.node_pool.id
}

output "tags" {
  description = "Specifies the tags of the node pool"
  value       = azurerm_kubernetes_cluster_node_pool.node_pool.tags
}