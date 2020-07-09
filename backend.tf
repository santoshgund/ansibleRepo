#
# Created backend storage manually:
# "rg-terraform" Resource Group
# "walttiproterraform" ZRS Storage Account
# "terraform" Container
#

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "walttiproterraform"
    container_name       = "terraform"
    key                  = "tfstate.dev"
  }
}
