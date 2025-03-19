variable "cluster_id" {
  description = "(Required) Specifies the resource id of the AKS cluster"
  type        = string
}

variable "dapr_enabled" {
  description = "(Optional) Specifies whether the DAPR extension should be provisioned"
  type        = bool
  default     = false
}

variable "flux_enabled" {
  description = "(Optional) Specifies whether the FLUX extension should be provisioned"
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