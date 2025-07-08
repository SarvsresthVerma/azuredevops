module "resource_group_name" {
  source                  = "../module/azurerm_resource_group"
  resource_group_name     = "rg_todo"
  resource_group_location = "east us"
}

module "virtual_network" {
  depends_on               = [module.resource_group_name]
  source                   = "../module/azurerm_vnet"
  virtual_network_name     = "vnet_todo"
  virtual_network_location = "west europe"
  resource_group_name      = "rg_todo"
  address_space            = ["10.0.0.0/24"]
}
module "frontendsubnet" {
  depends_on           = [module.virtual_network,module.resource_group_name]
  source               = "../module/azurerm_subnet"
  subnet_name          = "front_todo"
  resource_group_name  = "rg_todo"
  virtual_network_name = "vnet_todo"
  address_prefixes     = ["10.0.0.128/25"]
}
module "backendsubnet" {
  depends_on           = [module.virtual_network,module.resource_group_name]
  source               = "../module/azurerm_subnet"
  subnet_name          = "back_todo"
  resource_group_name  = "rg_todo"
  virtual_network_name = "vnet_todo"
  address_prefixes     = ["10.0.0.0/25"]
}

module "azurerm_vm_front_todo" {
  source                     = "../module/azurerm_vm"
  depends_on                 = [module.frontendsubnet, module.azurerm_public_front_ip, module.named_azurerm_key_vault, module.vm_username, module.vm_password,module.resource_group_name, module.virtual_network]
  
  network_interface_name     = "nic_front_todo"
  network_interface_location = "westeurope"
  resource_group_name        = "rg_todo"
  subnet_name                = "front_todo"
  virtual_network_name       = "vnet_todo"
  public_ip_name             = "pip_front_todo"

  vm_name                    = "vm_front_todo"
  vm_location                = "westeurope"
  size                       = "Standard_B1s"
  image_publisher            = "Canonical"
  image_offer                = "0001-com-ubuntu-server-jammy"
  image_sku                  = "22_04-lts-gen2"
  image_version              = "latest"

  key_vault_name             = "kv-todoapp"
  username_secret_name       = "vm-username"
  password_secret_name       = "vm-password"
}

module "azurerm_backend_vm_todo" {
  source                     = "../module/azurerm_vm"
  depends_on                 = [module.frontendsubnet, module.azurerm_public_front_ip, module.named_azurerm_key_vault, module.vm_username, module.vm_password,module.resource_group_name, module.virtual_network]

  network_interface_name     = "nic_front_todo"
  network_interface_location = "westeurope"
  resource_group_name        = "rg_todo"
  subnet_name                = "front_todo"
  virtual_network_name       = "vnet_todo"
  public_ip_name             = "pip_front_todo"

  vm_name                    = "vm_front_todo"
  vm_location                = "westeurope"
  size                       = "Standard_B1s"
  image_publisher            = "Canonical"
  image_offer                = "0001-com-ubuntu-server-jammy"
  image_sku                  = "22_04-lts-gen2"
  image_version              = "latest"

  key_vault_name             = "kv-todoapp"
  username_secret_name       = "vm-username"
  password_secret_name       = "vm-password"
}


module "sql_server" {
  source                       = "../module/sql_server"
  sql_server_name              = "todosqlserver007"
  resource_group_name          = "rg_todo"
  location                     = "centralindia"
  administrator_login          = "azureuser"
  administrator_login_password = "Sarv@1234567"
}
module "named_azuerm_sql_database" {
  depends_on           = [ module.sql_server ]
  source               = "../module/sql_database"
  sql_database_name    = "tododb"
  sql_server_name      = "todosqlserver007"   
  resource_group_name  = "rg_todo"
  
}

module "azurerm_public_front_ip" {

  source              = "../module/azurerm_public_ip"
  public_ip_name      = "pip_front_todo"
  location            = "west europe"
  allocation_method   = "Static"
  resource_group_name = "rg_todo"

}

module "azurerm_public_backend_ip" {
  source              = "../module/azurerm_public_ip"
  public_ip_name      = "pip_back_todo"
  location            = "west europe"
  allocation_method   = "Static"
  resource_group_name = "rg_todo"
}

module "named_azurerm_key_vault" {
  depends_on = [ module.resource_group_name]
  source                  = "../module/azurerm_key_vault"
  key_vault_name          = "kv-todoapp"
  location                = "centralindia"
  resource_group_name     = "rg_todo"
  
}
module "vm_username" {
  depends_on           = [module.named_azurerm_key_vault,module.resource_group_name]
  source               = "../module/azurerm_secrect"
  key_vault_name      = "kv-todoapp"
  secret-name         = "vm-username"
  secret_value        = "azureuser"
  resource_group_name = "rg_todo"
  
}
module "vm_password" {
  depends_on           = [ module.vm_username]
  source               = "../module/azurerm_secrect"
  key_vault_name      = "kv-todoapp"
  secret-name         = "vm-password"
  secret_value        = "Sarv@1234567"
  resource_group_name = "rg_todo"
  
} 