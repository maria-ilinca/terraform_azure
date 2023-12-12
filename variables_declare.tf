# variables.tf

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "ilinca"  
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East Europe"  
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "ilinca-vnet"  
}

variable "public_subnet_name" {
  description = "Name of the Public Subnet"
  type        = string
  default     = "public-subnet" 
}

variable "private_subnet_name" {
  description = "Name of the Private Subnet"
  type        = string
  default     = "private-subnet"  
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_DS1_v2" 
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "admin"  
}

variable "admin_password" {
  description = "Admin password for the virtual machine"
  type        = string
  default     = "AdminPassword1234!"  
}

variable "allowed_public_ip" {
  description = "Public IP allowed to access Apache"
  type        = string
  default     = "10.0.1.0/24"  
}

