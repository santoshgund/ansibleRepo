#
# Network Security Group for the test virtual machine
# allow: SSH (tcp/22), RDP (tcp/3389), ICMP (all)

resource "azurerm_network_security_group" "nsg_windows" {
  name                = "nsg-${local.azure_environment}-windows"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.development.name

  depends_on = [azurerm_resource_group.development]
}

resource "azurerm_network_security_rule" "allow_window_ssh" {
  name                        = "Allow SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.development.name
  network_security_group_name = azurerm_network_security_group.nsg_windows.name
}

resource "azurerm_network_security_rule" "allow_window_icmp" {
  name                        = "Allow ICMP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.development.name
  network_security_group_name = azurerm_network_security_group.nsg_windows.name
}

resource "azurerm_network_security_rule" "allow_window_rdp" {
  name                        = "Allow RDP"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.development.name
  network_security_group_name = azurerm_network_security_group.nsg_windows.name
}

resource "azurerm_network_security_rule" "allow_window_winrm" {
  name                        = "Allow WinRM"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5986"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.development.name
  network_security_group_name = azurerm_network_security_group.nsg_windows.name
}

resource "azurerm_network_security_rule" "allow_window_http" {
  name                        = "Allow HTTP"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.development.name
  network_security_group_name = azurerm_network_security_group.nsg_windows.name
}

