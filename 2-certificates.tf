data "azurerm_client_config" "current" {
  #tenant_id = "cbede638-a3d9-459f-8f4e-24ced73b4e5e"

}

# Generate a random vm name
resource "random_string" "key-vault-name" {
  length  = 6
  upper   = false
  number  = false
  lower   = true
  special = false
}


resource "azurerm_key_vault" "example" {
  name                = "${random_string.key-vault-name.result}keyvault"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.development.name
  tenant_id           = var.tanant_id

  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  sku_name = "standard"

  access_policy {
    tenant_id = var.tanant_id
    object_id = "${data.azurerm_client_config.current.object_id}"

    certificate_permissions = [
      "create",
      "delete",
      "get",
      "update",
    ]

    key_permissions    = []
    secret_permissions = []
  }
}

resource "azurerm_key_vault_certificate" "example" {
  name         = "${var.azure_vm["test-windows"].name}-cert"
  key_vault_id = "${azurerm_key_vault.example.id}"

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=${azurerm_public_ip.nic-test-windows-vm.ip_address}"
      validity_in_months = 12
    }
  }

  depends_on = [
    azurerm_resource_group.development,
    azurerm_network_security_group.nsg_windows,
    azurerm_subnet.development,
    azurerm_public_ip.nic-test-windows-vm
  ]
}
