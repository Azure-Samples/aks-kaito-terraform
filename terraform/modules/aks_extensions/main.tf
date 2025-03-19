resource "azurerm_kubernetes_cluster_extension" "dapr" {
  count             = var.dapr_enabled ? 1 : 0
  name              = "dapr"
  cluster_id        = var.cluster_id
  extension_type    = "Microsoft.Dapr"
  release_namespace = "dapr-system"
}

resource "azurerm_kubernetes_cluster_extension" "flux" {
  count          = var.flux_enabled ? 1 : 0
  name           = "flux"
  cluster_id     = var.cluster_id
  extension_type = "microsoft.flux"

  depends_on = [
    azurerm_kubernetes_cluster_extension.dapr
  ]
}

resource "azurerm_kubernetes_flux_configuration" "flux_config" {
  count      = var.flux_enabled ? 1 : 0
  name       = "aks-flux-extension"
  cluster_id = var.cluster_id
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url                      = var.flux_url
    reference_type           = "branch"
    reference_value          = var.flux_branch
    timeout_in_seconds       = 600
    sync_interval_in_seconds = 30
  }

  kustomizations {
    name                       = "apps"
    path                       = var.flux_kustomization_path
    timeout_in_seconds         = 600
    sync_interval_in_seconds   = 120
    retry_interval_in_seconds  = 300
    garbage_collection_enabled = true
    depends_on                 = []
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.flux
  ]
}