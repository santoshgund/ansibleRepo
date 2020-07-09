resource "azurerm_resource_group" "development" {
  name     = "rg-${local.azure_environment}"
  location = var.azure_region
}

resource "azurerm_virtual_network" "development" {
  name                = "vnet-${local.azure_environment}"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.development.name
  address_space       = local.azure_vnet.cidr

  depends_on = [azurerm_resource_group.development]
}

resource "azurerm_subnet" "development" {
  name                                           = "snet-${local.azure_environment}"
  resource_group_name                            = azurerm_resource_group.development.name
  virtual_network_name                           = azurerm_virtual_network.development.name
  address_prefix                                 = local.azure_vnet.subnet_cidr
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true

  depends_on = [
    azurerm_resource_group.development,
    azurerm_virtual_network.development
  ]
}
