variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "aks-argocd-rg"
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "westus3"
}

variable "aks_cluster_name" {
  type    = string
  default = "aks-argocd-cluster"
}

