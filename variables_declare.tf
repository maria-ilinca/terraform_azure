# storing the variables

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "example-resources"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East Europe"  # Change to your preferred region
}

variable "vnet_name" {
  description = "Name of the Azure virtual network"
  type        = string
  default     = "example-vnet"
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
  default     = "public-subnet"
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
  default     = "private-subnet"
}

variable "vm_size" {
  description = "Size of the virtual machine in the public subnet"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Admin password for the virtual machine"
  type        = string
  default     = "AdminPassword1234!" 
}

variable "allowed_public_ip" {
  description = "Public IP allowed to access Apache"
  type        = string
  default     = "<allowed_public_ip>"  
}
