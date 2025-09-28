variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "opendid-rg"
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "westus3"
}

variable "my_public_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "key_path" {
  description = "Azure Subscription ID"
  type        = string
}
