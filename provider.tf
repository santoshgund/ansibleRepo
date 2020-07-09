#
# AzureRM provider

provider "azurerm" {
  version = "~> 2.0"

  subscription_id = var.azure_subscription

  features {}
}
