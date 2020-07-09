resource "azurerm_public_ip" "nic-test-windows-vm" {
  name                = "pip-${local.azure_environment}-test-windows-vm"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.development.name
  allocation_method   = "Static"
}

#
# NIC for test virtual machine
resource "azurerm_network_interface" "nic-test-windows-vm" {
  name                = "nic-${local.azure_environment}-test-windows-vm"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.development.name

  ip_configuration {
    name                          = "nic-config-${local.azure_environment}-test-windows-vm"
    subnet_id                     = azurerm_subnet.development.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nic-test-windows-vm.id
  }

  depends_on = [azurerm_subnet.development]
}

#
# Network Security Group assignment to NIC (for azurerm 2.0)
resource "azurerm_network_interface_security_group_association" "nic-nsg-test-windows-vm" {
  network_interface_id      = azurerm_network_interface.nic-test-windows-vm.id
  network_security_group_id = azurerm_network_security_group.nsg_windows.id
}

locals {
  custom_data_params  = "Param($ComputerName = \"${azurerm_public_ip.nic-test-windows-vm.ip_address}\")"
  custom_data_content = "${local.custom_data_params} ${file("./files/winrm.ps1")}"
}



# Virtual machine
resource "azurerm_virtual_machine" "vm-windows-test" {
  name                  = var.azure_vm["test-windows"].name
  location              = var.azure_region
  resource_group_name   = azurerm_resource_group.development.name
  network_interface_ids = [azurerm_network_interface.nic-test-windows-vm.id]
  vm_size               = var.azure_vm["test-windows"].vm_type
  tags                  = var.azure_vm["test-windows"].vm_tags

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  # delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${azurerm_resource_group.development.name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.azure_vm["test-windows"].name
    admin_username = var.azure_vm["test-windows"].vm_admin_account
    admin_password = var.azure_vm["test-windows"].vm_admin_password
    custom_data    = "${local.custom_data_content}"
  }

  os_profile_secrets {
    source_vault_id = "${azurerm_key_vault.example.id}"

    vault_certificates {
      certificate_url   = "${azurerm_key_vault_certificate.example.secret_id}"
      certificate_store = "My"
    }
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true

    # Auto-Login's required to configure WinRM
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.azure_vm["test-windows"].vm_admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.azure_vm["test-windows"].vm_admin_account}</Username></AutoLogon>"
    }

    # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = "${file("./files/FirstLogonCommands.xml")}"
    }
  }

  provisioner "remote-exec" {
    connection {
      user     = var.azure_vm["test-windows"].vm_admin_account
      password = var.azure_vm["test-windows"].vm_admin_password
      port     = 5986
      https    = true
      timeout  = "5m"
      host     = azurerm_public_ip.nic-test-windows-vm.ip_address
      type     = "winrm"
      use_ntlm = true

      # NOTE: if you're using a real certificate, rather than a self-signed one, you'll want this set to `false`/to remove this.
      insecure = true
    }

    inline = [
      "cd C:\\Windows",
      "dir",
    ]
  }

  depends_on = [
    azurerm_resource_group.development,
    azurerm_network_security_group.nsg_windows,
    azurerm_subnet.development,
    azurerm_public_ip.nic-test-windows-vm
  ]
}

output "public_ip_address" {
  value = azurerm_public_ip.nic-test-windows-vm.ip_address
}
