variable "name_prefix" {
  description = "(Optional) A prefix for the name of all the resource groups and resources."
  type        = string
  nullable    = true
}

variable "log_analytics_workspace_name" {
  description = "Specifies the name of the log analytics workspace"
  default     = "Workspace"
  type        = string
}

variable "solution_plan_map" {
  description = "Specifies solutions to deploy to log analytics workspace"
  default = {
    ContainerInsights = {
      product   = "OMSGallery/ContainerInsights"
      publisher = "Microsoft"
    }
  }
  type = map(any)
}

variable "location" {
  description = "Specifies the location for the resource group and all the resources"
  default     = "northeurope"
  type        = string
}

variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  default     = "RG"
  type        = string
}

variable "vnet_name" {
  description = "Specifies the name of the AKS subnet"
  default     = "VNet"
  type        = string
}

variable "vnet_address_space" {
  description = "Specifies the address prefix of the AKS subnet"
  default     = ["10.0.0.0/8"]
  type        = list(string)
}

variable "system_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the system node pool"
  default     = "SystemSubnet"
  type        = string
}

variable "system_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the system node pool"
  default     = ["10.240.0.0/16"]
  type        = list(string)
}

variable "user_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the user node pool"
  default     = "UserSubnet"
  type        = string
}

variable "user_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the user node pool"
  type        = list(string)
  default     = ["10.241.0.0/16"]
}

variable "pod_subnet_name" {
  description = "Specifies the name of the jumpbox subnet"
  default     = "PodSubnet"
  type        = string
}

variable "pod_subnet_address_prefix" {
  description = "Specifies the address prefix of the jumbox subnet"
  default     = ["10.242.0.0/16"]
  type        = list(string)
}

variable "api_server_subnet_name" {
  description = "Specifies the address prefix of the API Server subnet, when API Server VNET Integration is enabled."
  default     = "ApiServerSubnet"
  type        = string
}

variable "api_server_subnet_address_prefix" {
  description = "Specifies the address prefix of the API Server subnet, when API Server VNET Integration is enabled."
  default     = ["10.243.0.0/27"]
  type        = list(string)
}

variable "vm_subnet_name" {
  description = "Specifies the name of the subnet that contains the jumpbox virtual machine and private endpoints."
  default     = "VmSubnet"
  type        = string
}

variable "vm_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that contains the jumpbox virtual machine and private endpoints."
  default     = ["10.243.1.0/24"]
  type        = list(string)
}

variable "bastion_subnet_address_prefix" {
  description = "Specifies the address prefix of the firewall subnet"
  default     = ["10.243.2.0/24"]
  type        = list(string)
}

variable "aks_cluster_name" {
  description = "(Required) Specifies the name of the AKS cluster."
  default     = "Aks"
  type        = string
}

variable "private_cluster_enabled" {
  description = "(Optional) Specifies wether the AKS cluster be private or not."
  default     = false
  type        = bool
}

variable "role_based_access_control_enabled" {
  description = "(Required) Is Role Based Access Control Enabled? Changing this forces a new resource to be created."
  default     = true
  type        = bool
}

variable "automatic_upgrade_channel" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Omitting this field sets this value to none."
  default     = "patch"
  type        = string

  validation {
    condition     = contains(["patch", "rapid", "stable", "node-image"], var.automatic_upgrade_channel)
    error_message = "The upgrade mode is invalid."
  }
}

variable "node_os_upgrade_channel" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are Unmanaged, SecurityPatch, NodeImage and None. Defaults to NodeImage."
  default     = "NodeImage"
  type        = string

  validation {
    condition     = contains(["Unmanaged", "SecurityPatch", "NodeImage"], var.node_os_upgrade_channel)
    error_message = "The upgrade mode is invalid."
  }
}

variable "admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  default     = []
  type        = list(string)
}

variable "azure_rbac_enabled" {
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
  default     = true
  type        = bool
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard (which includes the Uptime SLA) and Premium. Defaults to Free."
  default     = "Free"
  type        = string

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "The sku tier is invalid."
  }
}

variable "kubernetes_version" {
  description = "Specifies the AKS Kubernetes version"
  type        = string
}

variable "system_node_pool_vm_size" {
  description = "Specifies the vm size of the system node pool"
  default     = "Standard_F16s_v2"
  type        = string
}

variable "system_node_pool_availability_zones" {
  description = "Specifies the availability zones of the system node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "dns_service_ip" {
  description = "Specifies the DNS service IP"
  default     = "172.16.0.10"
  type        = string
}

variable "service_cidr" {
  description = "Specifies the service CIDR"
  default     = "172.16.0.0/16"
  type        = string
}

variable "pod_cidr" {
  description = "Specifies the service CIDR"
  default     = "192.168.0.0/16"
  type        = string
}

variable "network_plugin" {
  description = "Specifies the network plugin of the AKS cluster"
  default     = "azure"
  type        = string
}

variable "network_plugin_mode" {
  description = "(Optional) Specifies the network plugin mode used for building the Kubernetes network. Possible value is overlay."
  default     = null
  type        = string
}

variable "network_mode" {
  description = "(Optional) Network mode to be used with Azure CNI. Possible values are bridge and transparent. Changing this forces a new resource to be created."
  default     = "transparent"
  type        = string

  validation {
    condition     = contains([null, "bridge", "transparent"], var.network_mode)
    error_message = "The network mode is invalid."
  }
}

variable "network_policy" {
  description = " (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico, azure and cilium."
  default     = "azure"
  type        = string

  validation {
    condition     = contains([null, "azure", "calico", "cilium"], var.network_policy)
    error_message = "The network policy is invalid."
  }
}

variable "annotations_allowed" {
  description = "(Optional) Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric."
  type        = string
  default     = null
}

variable "labels_allowed" {
  description = "(Optional) Specifies a Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric."
  type        = string
  default     = null
}

variable "authorized_ip_ranges" {
  description = "(Optional) Set of authorized IP ranges to allow access to API server."
  type        = list(string)
  default     = []
}

variable "vnet_integration_enabled" {
  description = "(Optional) Should API Server VNet Integration be enabled? For more details please visit Use API Server VNet Integration."
  type        = bool
  default     = false
}

variable "system_node_pool_name" {
  description = "Specifies the name of the system node pool"
  default     = "system"
  type        = string
}

variable "system_node_pool_auto_scaling_enabled" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

variable "system_node_pool_host_encryption_enabled" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "system_node_pool_node_public_ip_enabled" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "system_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "system_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "system_node_pool_only_critical_addons_enabled" {
  description = "(Optional) Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint. temporary_name_for_rotation must be specified when changing this property."
  type        = bool
  default     = true
}

variable "system_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

variable "system_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 10
}

variable "system_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 3
}

variable "system_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 3
}

variable "user_node_pool_name" {
  description = "(Required) Specifies the name of the node pool."
  type        = string
  default     = "user"
}

variable "user_node_pool_vm_size" {
  description = "(Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard_F16s_v2"
}

variable "user_node_pool_availability_zones" {
  description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "user_node_pool_auto_scaling_enabled" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

variable "user_node_pool_host_encryption_enabled" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "user_node_pool_node_public_ip_enabled" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "user_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "user_node_pool_mode" {
  description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
  type        = string
  default     = "User"
}

variable "user_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "user_node_pool_node_taints" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = list(string)
  default     = []
}

variable "user_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

variable "user_node_pool_os_type" {
  description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
  type        = string
  default     = "Linux"
}

variable "user_node_pool_priority" {
  description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  type        = string
  default     = "Regular"
}

variable "user_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 10
}

variable "user_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 3
}

variable "user_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 3
}

variable "vm_enabled" {
  description = "(Optional) Specifies whether create a virtual machine"
  type        = bool
  default     = false
}

variable "vm_name" {
  description = "Specifies the name of the jumpbox virtual machine"
  default     = "Vm"
  type        = string
}

variable "vm_public_ip" {
  description = "(Optional) Specifies whether create a public IP for the virtual machine"
  type        = bool
  default     = false
}

variable "vm_accelerated_networking_enabled" {
  description = "Specifies whether enable accelerated networking"
  type        = bool
  default     = true
}

variable "vm_size" {
  description = "Specifies the size of the jumpbox virtual machine"
  default     = "Standard_D4ads_v5"
  type        = string
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type of the os disk of the jumpbox virtual machine"
  default     = "Premium_LRS"
  type        = string

  validation {
    condition     = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"], var.vm_os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "storage_account_kind" {
  description = "(Optional) Specifies the account kind of the storage account"
  default     = "StorageV2"
  type        = string

  validation {
    condition     = contains(["Storage", "StorageV2"], var.storage_account_kind)
    error_message = "The account kind of the storage account is invalid."
  }
}

variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  default     = "Standard"
  type        = string

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}

variable "storage_account_shared_access_key_enabled" {
  description = "(Optional) Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). Defaults to true."
  default     = true
  type        = bool
}

variable "storage_account_virtual_network_subnet_ids" {
  description = "Specifies a list of resource ids for subnets"
  default     = []
  type        = list(string)
}

variable "storage_account_ip_rules" {
  description = "Specifies IP rules for the Azure Storage Account"
  default     = []
  type        = list(string)
}

variable "storage_account_bypass" {
  description = " (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None."
  default     = ["Logging", "Metrics", "AzureServices"]
  type        = set(string)
}

variable "storage_account_default_action" {
  description = "Allow or disallow public access to all blobs or containers in the Azure Storage Accounts. The default interpretation is true for this property."
  default     = "Allow"
  type        = string
}

variable "acr_name" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "Acr"
}

variable "acr_sku" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "acr_admin_enabled" {
  description = "Specifies whether admin is enabled for the container registry"
  type        = bool
  default     = true
}

variable "acr_georeplication_locations" {
  description = "(Optional) A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "(Optional) Specifies tags for all the resources"
  default = {
    createdWith = "Terraform"
  }
}

variable "bastion_host_name" {
  description = "(Optional) Specifies the name of the bastion host"
  default     = "BastionHost"
  type        = string
}

variable "storage_account_replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = "LRS"
  type        = string

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.storage_account_replication_type)
    error_message = "The replication type of the storage account is invalid."
  }
}

variable "key_vault_name" {
  description = "Specifies the name of the key vault."
  type        = string
  default     = "KeyVault"
}

variable "key_vault_sku_name" {
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "The sku name of the key vault is invalid."
  }
}

variable "key_vault_enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_disk_encryption" {
  description = " (Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault? Defaults to false."
  type        = bool
  default     = false
}

variable "key_vault_soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  type        = number
  default     = 30
}

variable "key_vault_bypass" {
  description = "(Required) Specifies which traffic can bypass the network rules. Possible values are AzureServices and None."
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.key_vault_bypass)
    error_message = "The valut of the bypass property of the key vault is invalid."
  }
}

variable "key_vault_default_action" {
  description = "(Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny."
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.key_vault_default_action)
    error_message = "The value of the default action property of the key vault is invalid."
  }
}

variable "admin_username" {
  description = "(Required) Specifies the admin username of the jumpbox virtual machine and AKS worker nodes."
  type        = string
  default     = "azadmin"
}

variable "ssh_public_key" {
  description = "(Required) Specifies the SSH public key for the jumpbox virtual machine and AKS worker nodes."
  type        = string
}

variable "keda_enabled" {
  description = "(Optional) Specifies whether KEDA Autoscaler can be used for workloads."
  type        = bool
  default     = true
}

variable "vertical_pod_autoscaler_enabled" {
  description = "(Optional) Specifies whether Vertical Pod Autoscaler should be enabled."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "(Optional) Specifies whether Azure AD Workload Identity should be enabled for the Cluster. Defaults to false."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "(Optional) Enable or Disable the OIDC issuer URL."
  type        = bool
  default     = true
}

variable "open_service_mesh_enabled" {
  description = "(Optional) Is Open Service Mesh enabled? For more details, please visit Open Service Mesh for AKS."
  type        = bool
  default     = true
}

variable "image_cleaner_enabled" {
  description = "(Optional) Specifies whether Image Cleaner is enabled."
  type        = bool
  default     = true
}

variable "image_cleaner_interval_hours" {
  type        = number
  default     = 48
  description = "(Optional) Specifies the interval in hours when images should be cleaned up. Defaults to `48`."
}

variable "azure_policy_enabled" {
  description = "(Optional) Should the Azure Policy Add-On be enabled? For more details please visit Understand Azure Policy for Azure Kubernetes Service"
  type        = bool
  default     = true
}

variable "cost_analysis_enabled" {
  description = "(Optional) Should cost analysis be enabled for this Kubernetes Cluster? Defaults to false. The sku_tier must be set to Standard or Premium to enable this feature. Enabling this will add Kubernetes Namespace and Deployment details to the Cost Analysis views in the Azure portal."
  type        = bool
  default     = false
}

variable "http_application_routing_enabled" {
  description = "(Optional) Should HTTP Application Routing be enabled?"
  type        = bool
  default     = false
}

variable "openai_enabled" {
  description = "(Required) Specifies whether deploy Azure OpenAI Service or not."
  type        = bool
  default     = false
}

variable "openai_name" {
  description = "(Required) Specifies the name of the Azure OpenAI Service"
  type        = string
  default     = "OpenAi"
}

variable "openai_sku_name" {
  description = "(Optional) Specifies the sku name for the Azure OpenAI Service"
  type        = string
  default     = "S0"
}

variable "openai_custom_subdomain_name" {
  description = "(Optional) Specifies the custom subdomain name of the Azure OpenAI Service"
  type        = string
  nullable    = true
  default     = ""
}

variable "openai_public_network_access_enabled" {
  description = "(Optional) Specifies whether public network access is allowed for the Azure OpenAI Service"
  type        = bool
  default     = true
}

variable "openai_local_auth_enabled" {
  description = "(Optional) Whether local authentication methods is enabled for the Cognitive Account. Defaults to true."
  type        = bool
  default     = true
}

variable "openai_deployments" {
  description = "(Optional) Specifies the deployments of the Azure OpenAI Service"
  type = list(object({
    name = string
    model = object({
      name    = string
      version = string
      sku     = string
    })
  }))
  default = []
}

variable "nat_gateway_name" {
  description = "(Required) Specifies the name of the Azure OpenAI Service"
  type        = string
  default     = "NatGateway"
}

variable "nat_gateway_sku_name" {
  description = "(Optional) The SKU which should be used. At this time the only supported value is Standard. Defaults to Standard"
  type        = string
  default     = "Standard"
}

variable "nat_gateway_idle_timeout_in_minutes" {
  description = "(Optional) The idle timeout which should be used in minutes. Defaults to 4."
  type        = number
  default     = 4
}

variable "nat_gateway_zones" {
  description = " (Optional) A list of Availability Zones in which this NAT Gateway should be located. Changing this forces a new NAT Gateway to be created."
  type        = list(string)
  default     = ["1"]
}

variable "workload_managed_identity_name" {
  description = "(Required) Specifies the name of the workload user-defined managed identity."
  type        = string
  default     = "WorkloadManagedIdentity"
}

variable "certificate_manager_managed_identity_name" {
  description = "(Required) Specifies the name of the cert-manager user-defined managed identity."
  type        = string
  default     = "CertificateManagerManagedIdentity"
}

variable "subdomain" {
  description = "Specifies the subdomain of the Kubernetes ingress object."
  type        = string
  default     = "chainlit"
}

variable "domain" {
  description = "Specifies the domain of the Kubernetes ingress object."
  type        = string
  default     = "contoso.com"
}

variable "namespace" {
  description = "Specifies the namespace of the workload application that accesses the Azure OpenAI Service."
  type        = string
  default     = "chainlit"
}

variable "service_account_name" {
  description = "Specifies the name of the service account of the workload application that accesses the Azure OpenAI Service."
  type        = string
  default     = "chainlit-sa"
}

variable "email" {
  description = "Specifies the email address for the cert-manager cluster issuer."
  type        = string
  default     = "paolos@microsoft.com"
}

variable "deployment_script_name" {
  description = "(Required) Specifies the name of the Azure OpenAI Service"
  type        = string
  default     = "BashScript"
}

variable "deployment_script_azure_cli_version" {
  description = "(Required) Azure CLI module version to be used."
  type        = string
  default     = "2.9.1"
}

variable "deployment_script_managed_identity_name" {
  description = "Specifies the name of the user-defined managed identity used by the deployment script."
  type        = string
  default     = "ScriptManagedIdentity"
}

variable "deployment_script_primary_script_uri" {
  description = "(Optional) Uri for the script. This is the entry point for the external script. Changing this forces a new Resource Deployment Script to be created."
  type        = string
  default     = "https://paolosalvatori.blob.core.windows.net/scripts/install-packages-for-chainlit-demo.sh"
}

variable "dns_zone_name" {
  description = "Specifies the name of the DNS zone."
  type        = string
  default     = null
}

variable "dns_zone_resource_group_name" {
  description = "Specifies the name of the resource group that contains the DNS zone."
  type        = string
  default     = null
}

variable "web_app_routing_enabled" {
  description = "(Optional) Should Web App Routing be enabled?"
  type        = bool
  default     = false
}

variable "key_vault_secrets_provider" {
  description = "Specifies the Azure Key Kault Secrets CSI Driver configuration."
  type = object({
    enabled                  = bool
    secret_rotation_enabled  = bool
    secret_rotation_interval = string
  })
  default = {
    enabled                  = true
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
}

variable "prometheus_name" {
  description = "Specifies the name of the Azure Managed Prometheus workspace."
  type        = string
  default     = "Prometheus"
}

variable "prometheus_public_network_access_enabled" {
  description = "(Optional) Specifies whether to enable traffic over the public interface for the Azure Managed Prometheus workspace. Defaults to true."
  type        = bool
  default     = true
}

variable "grafana_name" {
  description = "Specifies the name of the Azure Managed Grafana instance."
  type        = string
  default     = "Grafana"
}

variable "grafana_public_network_access_enabled" {
  description = "(Optional) Specifies whether to enable traffic over the public interface for the Azure Managed Grafana instance. Defaults to true."
  type        = bool
  default     = true
}

variable "grafana_sku" {
  description = "(Optional) Specifies the name of the SKU used for the Azure Managed Grafana resource. Possible values are Standard and Essential. Defaults to Standard. Changing this forces a new Dashboard Grafana to be created."
  type        = string
  default     = "Standard"
}

variable "grafana_zone_redundancy_enabled" {
  description = "(Optional) Specifies whether to enable zone redundancy for the Azure Managed Grafana resource. Defaults to false. Changing this forces a new Dashboard Grafana to be created."
  type        = bool
  default     = false
}

variable "grafana_admin_user_object_id" {
  description = "(Required) The object id of a Microsoft Entra ID user who should be assigned the Grafana Admin role over the Azure Managed Grafana resource."
  type        = string
  default     = null
}

variable "kaito_enabled" {
  description = "(Optional) Should Kaito be enabled?"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "(Optional) Specifies the GPU node SKU. This field defaults to Standard_NC12s_v3 if not specified."
  type        = string
  default     = "Standard_NC12s_v3"
}

variable "dapr_enabled" {
  description = "(Optional) Should DAPR extension be enabled?"
  type        = bool
  default     = false
}

variable "flux_enabled" {
  description = "(Optional) Should FLUX extension be enabled?"
  type        = bool
  default     = false
}

variable "flux_url" {
  description = "(Optional) Specifies the URL of the Git repository containing the Flux configuration."
  type        = string
  default     = null
}

variable "flux_branch" {
  description = "(Optional) Specifies the branch of the Git repository containing the Flux configuration."
  type        = string
  default     = null
}

variable "flux_kustomization_path" {
  description = "(Optional) Specifies the path of the Git repository containing the Kustomization configuration."
  type        = string
  default     = null
}