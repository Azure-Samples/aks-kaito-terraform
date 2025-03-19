name_prefix                               = "<name-prefix>" # "Contoso"
domain                                    = "<domain-name>" # "example.com"
kubernetes_version                        = "1.31.2"
network_plugin                            = "azure"
network_plugin_mode                       = "overlay"
network_policy                            = "azure"
sku_tier                                  = "Standard"
cost_analysis_enabled                     = true
system_node_pool_vm_size                  = "Standard_D4ds_v4" #Standard_F8s_v2
user_node_pool_vm_size                    = "Standard_D4ds_v4" #Standard_D4ads_v5
ssh_public_key                            = "ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
vm_enabled                                = true
location                                  = "eastus"
admin_group_object_ids                    = ["XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"]
web_app_routing_enabled                   = true
dns_zone_name                             = "<domain-name>" # "example.com"
dns_zone_resource_group_name              = "<dns-resource-group-name>"
namespace                                 = "kaito-demo"
service_account_name                      = "kaito-sa"
grafana_admin_user_object_id              = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
vnet_integration_enabled                  = true
openai_enabled                            = false # Flip to true if you want to deploy Azure OpenAI Service
openai_local_auth_enabled                 = false
storage_account_shared_access_key_enabled = true
storage_account_default_action            = "Deny"
kaito_enabled                             = true
dapr_enabled                              = true
annotations_allowed                       = null
instance_type                             = "Standard_NC12s_v3" # Standard_NC12, Standard_NC12s_v3, Standard_NV12s_v2, Standard_NV8as_v4
system_node_pool_availability_zones       = ["1", "2", "3"]
user_node_pool_availability_zones         = ["1", "2", "3"]
acr_name                                  = "Acr"
vm_size                                   = "Standard_D4ds_v4"
openai_deployments = [
  {
    name = "gpt-4o"
    model = {
      name    = "gpt-4o"
      version = "2024-08-06"
      sku     = "GlobalStandard"
    }
  },
  {
    name = "text-embedding-ada-002"
    model = {
      name    = "text-embedding-ada-002"
      version = "2"
      sku     = "Standard"
    }
  }
]