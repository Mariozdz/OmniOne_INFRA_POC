terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.44.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli = true
  subscription_id = var.subscription_id
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  
}

variable "my_ip" {
  description = "Tu IP pública para acceder al API server"
  default     = "X.X.X.X/32" # reemplaza con tu IP pública
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet privada para AKS
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP para el NAT Gateway
resource "azurerm_public_ip" "nat_ip" {
  name                = "nat-gateway-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NAT Gateway
resource "azurerm_nat_gateway" "nat" {
  name                = "nat-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"

}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat_ip.id
}


# Asociación NAT Gateway ↔ Subnet
resource "azurerm_subnet_nat_gateway_association" "subnet_nat" {
  subnet_id      = azurerm_subnet.subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

# AKS privado
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-private"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksprivate"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

    network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    dns_service_ip = "10.2.0.10"
    service_cidr   = "10.2.0.0/24"
  }

  api_server_access_profile {
    authorized_ip_ranges   = ["0.0.0.0/0"]  # permite tu IP pública
    
  }

}


## New
resource "kubernetes_namespace" "myapp" {
  depends_on = [ azurerm_kubernetes_cluster.aks ]
  metadata {
    name = "myapp"
  }
}

# resource "kubernetes_persistent_volume_claim" "mysql" {
#   depends_on = [ azurerm_kubernetes_cluster.aks ]
#   metadata {
#     name      = "mysql-pvc"
#     namespace = kubernetes_namespace.myapp.metadata[0].name
#   }

#   spec {
#     access_modes = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         storage = "1Gi"
#       }
#     }
#     storage_class_name = "default"
#   }
# }

resource "kubernetes_secret" "db_root_password" {
  depends_on = [ azurerm_kubernetes_cluster.aks ]
  metadata {
    name      = "db-root-password"
    namespace = kubernetes_namespace.myapp.metadata[0].name
  }

  data = {
    db_root_password = base64encode("MiRootPass123")  # valor de la contraseña
  }

  type = "Opaque"
}

resource "kubernetes_secret" "db_password" {
  depends_on = [ azurerm_kubernetes_cluster.aks ]
  metadata {
    name      = "db-password"
    namespace = kubernetes_namespace.myapp.metadata[0].name
  }

  data = {
    db_password = base64encode("MiUserPass123")  # valor de la contraseña
  }

  type = "Opaque"
}
