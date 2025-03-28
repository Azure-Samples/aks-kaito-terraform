locals {
  storage_account_prefix = "boot"
  cluster_name           = var.name_prefix == null ? "${random_string.prefix.result}${var.aks_cluster_name}" : "${var.name_prefix}${var.aks_cluster_name}"
  kaito_identity_name    = "ai-toolchain-operator-${lower(local.cluster_name)}"
}

data "azurerm_client_config" "current" {
}

resource "random_string" "prefix" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

resource "random_string" "storage_account_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.name_prefix == null ? "${random_string.prefix.result}${var.resource_group_name}" : "${var.name_prefix}${var.resource_group_name}"
  location = var.location
  tags     = var.tags
}

data "azurerm_dns_zone" "dns_zone" {
  count               = var.dns_zone_name != null && var.dns_zone_resource_group_name != null ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
}

module "log_analytics_workspace" {
  source              = "./modules/log_analytics"
  name                = var.name_prefix == null ? "${random_string.prefix.result}${var.log_analytics_workspace_name}" : "${var.name_prefix}${var.log_analytics_workspace_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  solution_plan_map   = var.solution_plan_map
  tags                = var.tags
}

module "virtual_network" {
  source                     = "./modules/virtual_network"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  vnet_name                  = var.name_prefix == null ? "${random_string.prefix.result}${var.vnet_name}" : "${var.name_prefix}${var.vnet_name}"
  address_space              = var.vnet_address_space
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = var.tags

  subnets = [
    {
      name : var.system_node_pool_subnet_name
      address_prefixes : var.system_node_pool_subnet_address_prefix
      private_endpoint_network_policies : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : null
    },
    {
      name : var.user_node_pool_subnet_name
      address_prefixes : var.user_node_pool_subnet_address_prefix
      private_endpoint_network_policies : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : null
    },
    lower(var.network_plugin_mode) != "overlay" ? {
      name : var.pod_subnet_name
      address_prefixes : var.pod_subnet_address_prefix
      private_endpoint_network_policies : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : "Microsoft.ContainerService/managedClusters"
    } : null,
    {
      name : var.api_server_subnet_name
      address_prefixes : var.api_server_subnet_address_prefix
      private_endpoint_network_policies : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : "Microsoft.ContainerService/managedClusters"
    },
    {
      name : "AzureBastionSubnet"
      address_prefixes : var.bastion_subnet_address_prefix
      private_endpoint_network_policies : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : null
    },
    {
      name : var.vm_subnet_name
      address_prefixes : var.vm_subnet_address_prefix
      private_endpoint_network_policies : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : null
    }
  ]
}

module "nat_gateway" {
  source                  = "./modules/nat_gateway"
  name                    = var.name_prefix == null ? "${random_string.prefix.result}${var.nat_gateway_name}" : "${var.name_prefix}${var.nat_gateway_name}"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = var.location
  sku_name                = var.nat_gateway_sku_name
  idle_timeout_in_minutes = var.nat_gateway_idle_timeout_in_minutes
  zones                   = var.nat_gateway_zones
  tags                    = var.tags
  subnet_ids              = module.virtual_network.subnet_ids
}

module "container_registry" {
  source                     = "./modules/container_registry"
  name                       = var.name_prefix == null ? "${random_string.prefix.result}${var.acr_name}" : "${var.name_prefix}${var.acr_name}"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  sku                        = var.acr_sku
  admin_enabled              = var.acr_admin_enabled
  georeplication_locations   = var.acr_georeplication_locations
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = var.tags

}

module "aks_cluster" {
  source                                        = "./modules/aks"
  name                                          = local.cluster_name
  location                                      = var.location
  resource_group_name                           = azurerm_resource_group.rg.name
  resource_group_id                             = azurerm_resource_group.rg.id
  kubernetes_version                            = var.kubernetes_version
  dns_prefix                                    = lower(local.cluster_name)
  private_cluster_enabled                       = var.private_cluster_enabled
  automatic_upgrade_channel                     = var.automatic_upgrade_channel
  node_os_upgrade_channel                       = var.node_os_upgrade_channel
  sku_tier                                      = var.sku_tier
  system_node_pool_name                         = var.system_node_pool_name
  system_node_pool_vm_size                      = var.system_node_pool_vm_size
  vnet_subnet_id                                = module.virtual_network.subnet_ids[var.system_node_pool_subnet_name]
  pod_subnet_id                                 = lower(var.network_plugin_mode) != "overlay" ? module.virtual_network.subnet_ids[var.pod_subnet_name] : null
  api_server_subnet_id                          = module.virtual_network.subnet_ids[var.api_server_subnet_name]
  system_node_pool_availability_zones           = var.system_node_pool_availability_zones
  system_node_pool_node_labels                  = var.system_node_pool_node_labels
  system_node_pool_only_critical_addons_enabled = var.system_node_pool_only_critical_addons_enabled
  system_node_pool_auto_scaling_enabled         = var.system_node_pool_auto_scaling_enabled
  system_node_pool_host_encryption_enabled      = var.system_node_pool_host_encryption_enabled
  system_node_pool_node_public_ip_enabled       = var.system_node_pool_node_public_ip_enabled
  system_node_pool_max_pods                     = var.system_node_pool_max_pods
  system_node_pool_max_count                    = var.system_node_pool_max_count
  system_node_pool_min_count                    = var.system_node_pool_min_count
  system_node_pool_node_count                   = var.system_node_pool_node_count
  system_node_pool_os_disk_type                 = var.system_node_pool_os_disk_type
  tags                                          = var.tags
  network_plugin                                = var.network_plugin
  network_mode                                  = lower(var.network_plugin) == "azure" ? var.network_mode : null
  network_plugin_mode                           = lower(var.network_plugin) == "azure" ? var.network_plugin_mode : null
  network_policy                                = var.network_policy
  outbound_type                                 = "userAssignedNATGateway"
  service_cidr                                  = var.service_cidr
  dns_service_ip                                = var.dns_service_ip
  pod_cidr                                      = var.pod_cidr
  log_analytics_workspace_id                    = module.log_analytics_workspace.id
  role_based_access_control_enabled             = var.role_based_access_control_enabled
  tenant_id                                     = data.azurerm_client_config.current.tenant_id
  admin_group_object_ids                        = var.admin_group_object_ids
  azure_rbac_enabled                            = var.azure_rbac_enabled
  admin_username                                = var.admin_username
  ssh_public_key                                = var.ssh_public_key
  keda_enabled                                  = var.keda_enabled
  vertical_pod_autoscaler_enabled               = var.vertical_pod_autoscaler_enabled
  workload_identity_enabled                     = var.workload_identity_enabled
  oidc_issuer_enabled                           = var.oidc_issuer_enabled
  open_service_mesh_enabled                     = var.open_service_mesh_enabled
  image_cleaner_enabled                         = var.image_cleaner_enabled
  image_cleaner_interval_hours                  = var.image_cleaner_interval_hours
  azure_policy_enabled                          = var.azure_policy_enabled
  cost_analysis_enabled                         = var.cost_analysis_enabled
  http_application_routing_enabled              = var.http_application_routing_enabled
  annotations_allowed                           = var.annotations_allowed
  labels_allowed                                = var.labels_allowed
  authorized_ip_ranges                          = var.authorized_ip_ranges
  vnet_integration_enabled                      = var.vnet_integration_enabled
  key_vault_secrets_provider                    = var.key_vault_secrets_provider
  kaito_enabled                                 = var.kaito_enabled

  web_app_routing = {
    enabled      = true
    dns_zone_ids = length(data.azurerm_dns_zone.dns_zone) > 0 ? [element(data.azurerm_dns_zone.dns_zone[*].id, 0)] : []
  }


  depends_on = [
    module.nat_gateway,
    module.container_registry
  ]
}

module "node_pool" {
  source                  = "./modules/node_pool"
  resource_group_name     = azurerm_resource_group.rg.name
  kubernetes_cluster_id   = module.aks_cluster.id
  name                    = var.user_node_pool_name
  vm_size                 = var.user_node_pool_vm_size
  mode                    = var.user_node_pool_mode
  node_labels             = var.user_node_pool_node_labels
  node_taints             = var.user_node_pool_node_taints
  availability_zones      = var.user_node_pool_availability_zones
  vnet_subnet_id          = module.virtual_network.subnet_ids[var.user_node_pool_subnet_name]
  pod_subnet_id           = lower(var.network_plugin_mode) != "overlay" ? module.virtual_network.subnet_ids[var.pod_subnet_name] : null
  auto_scaling_enabled    = var.user_node_pool_auto_scaling_enabled
  host_encryption_enabled = var.user_node_pool_host_encryption_enabled
  node_public_ip_enabled  = var.user_node_pool_node_public_ip_enabled
  orchestrator_version    = var.kubernetes_version
  max_pods                = var.user_node_pool_max_pods
  max_count               = var.user_node_pool_max_count
  min_count               = var.user_node_pool_min_count
  node_count              = var.user_node_pool_node_count
  os_type                 = var.user_node_pool_os_type
  priority                = var.user_node_pool_priority
  tags                    = var.tags

  depends_on = [module.aks_cluster
  ]
}

module "aks_extensions" {
  source       = "./modules/aks_extensions"
  cluster_id   = module.aks_cluster.id
  dapr_enabled = var.dapr_enabled
  flux_enabled = var.flux_enabled
  flux_url     = var.flux_url
  flux_branch  = var.flux_branch

  depends_on = [
    module.aks_cluster,
    module.node_pool
  ]
}

data "azurerm_resource_group" "node_resource_group" {
  count = var.kaito_enabled ? 1 : 0
  name  = module.aks_cluster.node_resource_group

  depends_on = [module.node_pool]
}

resource "azapi_update_resource" "enable_kaito" {
  count       = var.kaito_enabled ? 1 : 0
  type        = "Microsoft.ContainerService/managedClusters@2024-02-02-preview"
  resource_id = module.aks_cluster.id

  body = jsonencode({
    properties = {
      aiToolchainOperatorProfile = {
        enabled = var.kaito_enabled
      }
    }
  })

  depends_on = [
    module.node_pool,
    module.aks_extensions
  ]
}

data "azurerm_user_assigned_identity" "kaito_identity" {
  count               = var.kaito_enabled ? 1 : 0
  name                = local.kaito_identity_name
  resource_group_name = data.azurerm_resource_group.node_resource_group.0.name

  depends_on = [azapi_update_resource.enable_kaito]
}

resource "azurerm_federated_identity_credential" "kaito_federated_identity_credential" {
  count               = var.kaito_enabled ? 1 : 0
  name                = "kaito-federated-identity"
  resource_group_name = data.azurerm_resource_group.node_resource_group.0.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks_cluster.oidc_issuer_url
  parent_id           = data.azurerm_user_assigned_identity.kaito_identity.0.id
  subject             = "system:serviceaccount:kube-system:kaito-gpu-provisioner"

  depends_on = [azapi_update_resource.enable_kaito,
    module.aks_cluster,
  data.azurerm_user_assigned_identity.kaito_identity]
}

resource "azurerm_role_assignment" "kaito_identity_contributor_assignment" {
  count                            = var.kaito_enabled ? 1 : 0
  scope                            = azurerm_resource_group.rg.id
  role_definition_name             = "Contributor"
  principal_id                     = data.azurerm_user_assigned_identity.kaito_identity.0.principal_id
  skip_service_principal_aad_check = true

  depends_on = [azurerm_federated_identity_credential.kaito_federated_identity_credential]
}

resource "azurerm_user_assigned_identity" "aks_workload_identity" {
  name                = var.name_prefix == null ? "${random_string.prefix.result}${var.workload_managed_identity_name}" : "${var.name_prefix}${var.workload_managed_identity_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_user_assigned_identity" "certificate_manager_identity" {
  count               = var.dns_zone_name != null && var.dns_zone_resource_group_name != null ? 1 : 0
  name                = var.name_prefix == null ? "${random_string.prefix.result}${var.certificate_manager_managed_identity_name}" : "${var.name_prefix}${var.certificate_manager_managed_identity_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "dns_zone_contributor_user_assignment" {
  count                            = var.dns_zone_name != null && var.dns_zone_resource_group_name != null ? 1 : 0
  scope                            = data.azurerm_dns_zone.dns_zone.0.id
  role_definition_name             = "DNS Zone Contributor"
  principal_id                     = azurerm_user_assigned_identity.certificate_manager_identity.0.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "web_app_routing_identity_dns_zone_contributor_assignment" {
  count                            = var.dns_zone_name != null && var.dns_zone_resource_group_name != null ? 1 : 0
  scope                            = data.azurerm_dns_zone.dns_zone.0.id
  role_definition_name             = "DNS Zone Contributor"
  principal_id                     = module.aks_cluster.web_app_routing_identity_object_id
  skip_service_principal_aad_check = true

  depends_on = [
    module.aks_cluster
  ]
}

resource "azurerm_role_assignment" "key_vault_administrator_assignment" {
  count                            = var.key_vault_secrets_provider.enabled ? 1 : 0
  scope                            = module.key_vault.id
  role_definition_name             = "Key Vault Administrator"
  principal_id                     = module.aks_cluster.key_vault_secrets_provider_identity_object_id
  skip_service_principal_aad_check = true

  depends_on = [
    module.aks_cluster,
    module.key_vault
  ]
}

resource "azurerm_role_assignment" "cognitive_services_user_assignment" {
  count                            = var.openai_enabled ? 1 : 0
  scope                            = module.openai.0.id
  role_definition_name             = "Cognitive Services User"
  principal_id                     = azurerm_user_assigned_identity.aks_workload_identity.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_federated_identity_credential" "workload_federated_identity_credential" {
  name                = "${title(var.namespace)}FederatedIdentity"
  resource_group_name = azurerm_resource_group.rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks_cluster.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.aks_workload_identity.id
  subject             = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}

resource "azurerm_federated_identity_credential" "certificate_manager_federated_identity_credential" {
  count               = var.dns_zone_name != null && var.dns_zone_resource_group_name != null ? 1 : 0
  name                = "${title(var.certificate_manager_managed_identity_name)}FederatedIdentity"
  resource_group_name = azurerm_resource_group.rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks_cluster.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.certificate_manager_identity.0.id
  subject             = "system:serviceaccount:cert-manager:cert-manager"
}

resource "azurerm_role_assignment" "network_contributor_assignment" {
  scope                            = azurerm_resource_group.rg.id
  role_definition_name             = "Network Contributor"
  principal_id                     = module.aks_cluster.aks_identity_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr_pull_assignment" {
  role_definition_name             = "AcrPull"
  scope                            = module.container_registry.id
  principal_id                     = module.aks_cluster.kubelet_identity_object_id
  skip_service_principal_aad_check = true
}

module "kubernetes" {
  source                                         = "./modules/kubernetes"
  host                                           = module.aks_cluster.host
  username                                       = module.aks_cluster.username
  password                                       = module.aks_cluster.password
  client_key                                     = module.aks_cluster.client_key
  client_certificate                             = module.aks_cluster.client_certificate
  cluster_ca_certificate                         = module.aks_cluster.cluster_ca_certificate
  namespace                                      = var.namespace
  service_account_name                           = var.service_account_name
  email                                          = var.email
  tenant_id                                      = data.azurerm_client_config.current.tenant_id
  workload_managed_identity_client_id            = azurerm_user_assigned_identity.aks_workload_identity.client_id
  certificate_manager_managed_identity_client_id = var.dns_zone_name != null && var.dns_zone_resource_group_name != null ? azurerm_user_assigned_identity.certificate_manager_identity.0.client_id : ""
  dns_zone_name                                  = var.dns_zone_name
  dns_zone_resource_group_name                   = var.dns_zone_resource_group_name
  dns_zone_subscription_id                       = data.azurerm_client_config.current.subscription_id
  nginx_replica_count                            = 3
  kaito_enabled                                  = var.kaito_enabled
  instance_type                                  = var.instance_type
  grafana_id                                     = module.grafana.id
  grafana_tags                                   = module.grafana.tags
}

module "openai" {
  count                         = var.openai_enabled ? 1 : 0
  source                        = "./modules/openai"
  name                          = var.name_prefix == null ? "${random_string.prefix.result}${var.openai_name}" : "${var.name_prefix}${var.openai_name}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku_name                      = var.openai_sku_name
  tags                          = var.tags
  deployments                   = var.openai_deployments
  custom_subdomain_name         = var.openai_custom_subdomain_name == "" || var.openai_custom_subdomain_name == null ? var.name_prefix == null ? lower("${random_string.prefix.result}${var.openai_name}") : lower("${var.name_prefix}${var.openai_name}") : lower(var.openai_custom_subdomain_name)
  public_network_access_enabled = var.openai_public_network_access_enabled
  local_auth_enabled            = var.openai_local_auth_enabled
  log_analytics_workspace_id    = module.log_analytics_workspace.id
}

module "storage_account" {
  source                     = "./modules/storage_account"
  name                       = "${local.storage_account_prefix}${random_string.storage_account_suffix.result}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  account_kind               = var.storage_account_kind
  account_tier               = var.storage_account_tier
  replication_type           = var.storage_account_replication_type
  shared_access_key_enabled  = var.storage_account_shared_access_key_enabled
  ip_rules                   = var.storage_account_ip_rules
  virtual_network_subnet_ids = var.storage_account_virtual_network_subnet_ids
  default_action             = var.storage_account_default_action
  bypass                     = var.storage_account_bypass
  tags                       = var.tags
}

module "bastion_host" {
  source                     = "./modules/bastion_host"
  name                       = var.name_prefix == null ? "${random_string.prefix.result}${var.bastion_host_name}" : "${var.name_prefix}${var.bastion_host_name}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  subnet_id                  = module.virtual_network.subnet_ids["AzureBastionSubnet"]
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = var.tags
}

module "virtual_machine" {
  count                               = var.vm_enabled ? 1 : 0
  source                              = "./modules/virtual_machine"
  name                                = var.name_prefix == null ? "${random_string.prefix.result}${var.vm_name}" : "${var.name_prefix}${var.vm_name}"
  size                                = var.vm_size
  location                            = var.location
  public_ip                           = var.vm_public_ip
  vm_user                             = var.admin_username
  admin_ssh_public_key                = var.ssh_public_key
  os_disk_image                       = var.vm_os_disk_image
  resource_group_name                 = azurerm_resource_group.rg.name
  subnet_id                           = module.virtual_network.subnet_ids[var.vm_subnet_name]
  os_disk_storage_account_type        = var.vm_os_disk_storage_account_type
  boot_diagnostics_storage_account    = module.storage_account.primary_blob_endpoint
  log_analytics_workspace_id          = module.log_analytics_workspace.workspace_id
  log_analytics_workspace_key         = module.log_analytics_workspace.primary_shared_key
  log_analytics_workspace_resource_id = module.log_analytics_workspace.id
  accelerated_networking_enabled      = var.vm_accelerated_networking_enabled
  tags                                = var.tags

  depends_on = [
    module.storage_account,
    module.log_analytics_workspace,
    module.virtual_network,
    module.key_vault_private_endpoint
  ]
}

module "key_vault" {
  source                          = "./modules/key_vault"
  name                            = var.name_prefix == null ? "${random_string.prefix.result}${var.key_vault_name}" : "${var.name_prefix}${var.key_vault_name}"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_name
  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  bypass                          = var.key_vault_bypass
  default_action                  = var.key_vault_default_action
  log_analytics_workspace_id      = module.log_analytics_workspace.id
  tags                            = var.tags
}

module "acr_private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  virtual_networks_to_link = {
    (module.virtual_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

module "openai_private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  virtual_networks_to_link = {
    (module.virtual_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

module "key_vault_private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  virtual_networks_to_link = {
    (module.virtual_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

module "blob_private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  virtual_networks_to_link = {
    (module.virtual_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}

module "openai_private_endpoint" {
  count                          = var.openai_enabled ? 1 : 0
  source                         = "./modules/private_endpoint"
  name                           = "${module.openai.0.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.virtual_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.openai.0.id
  is_manual_connection           = false
  subresource_name               = "account"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.openai_private_dns_zone.id]

  depends_on = [
    module.virtual_network,
    module.key_vault_private_dns_zone,
  module.openai]
}

module "acr_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${module.container_registry.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.virtual_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.container_registry.id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.acr_private_dns_zone.id]

  depends_on = [
    module.virtual_network,
    module.acr_private_dns_zone,
    module.container_registry,
  module.openai_private_endpoint]
}

module "key_vault_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${module.key_vault.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.virtual_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.key_vault.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.key_vault_private_dns_zone.id]

  depends_on = [
    module.virtual_network,
    module.key_vault_private_dns_zone,
    module.key_vault,
    module.openai_private_endpoint,
  module.acr_private_endpoint]
}

module "blob_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = var.name_prefix == null ? "${random_string.prefix.result}BlocStoragePrivateEndpoint" : "${var.name_prefix}BlobStoragePrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.virtual_network.subnet_ids[var.vm_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.storage_account.id
  is_manual_connection           = false
  subresource_name               = "blob"
  private_dns_zone_group_name    = "BlobPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.blob_private_dns_zone.id]

  depends_on = [
    module.virtual_network,
    module.blob_private_dns_zone,
    module.key_vault,
    module.openai_private_endpoint,
    module.acr_private_endpoint,
  module.key_vault_private_endpoint]
}

module "prometheus" {
  source                        = "./modules/prometheus"
  name                          = var.name_prefix == null ? "${random_string.prefix.result}${var.prometheus_name}" : "${var.name_prefix}${var.prometheus_name}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  public_network_access_enabled = var.prometheus_public_network_access_enabled
  aks_cluster_id                = module.aks_cluster.id
  tags                          = var.tags

  depends_on = [module.aks_cluster]
}

module "grafana" {
  source                        = "./modules/grafana"
  name                          = var.name_prefix == null ? "${random_string.prefix.result}${var.grafana_name}" : "${var.name_prefix}${var.grafana_name}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  public_network_access_enabled = var.grafana_public_network_access_enabled
  azure_monitor_workspace_id    = module.prometheus.id
  sku                           = var.grafana_sku
  zone_redundancy_enabled       = var.grafana_zone_redundancy_enabled
  admin_group_object_id         = var.grafana_admin_user_object_id
  tags                          = var.tags

  depends_on = [azurerm_federated_identity_credential.kaito_federated_identity_credential]
}