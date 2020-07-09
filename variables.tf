#
# Variables

variable azure_subscription {
  type        = string
  description = "Azure Subscription ID"
  default     = "479674dc-2b4f-4f86-a1d6-cc7f74e93e82"
}

variable tanant_id {
  type        = string
  description = "Azure Subscription tanant ID"
  default     = "cbede638-a3d9-459f-8f4e-24ced73b4e5e"
}

variable azure_region {
  type        = string
  description = "Azure Region"
  default     = "westeurope"
}

variable azure_environment {
  type        = map(string)
  description = "Azure Environment names (by Terraform Workspace name)"
  default = {
    "default" = "development",
    "dev"     = "dev",
    "test"    = "test",
    "prod"    = "prod",
    "cat"     = "cat"
  }
}

variable azure_vnet {
  type = map(object({
    cidr        = list(string)
    subnet_cidr = string
  }))
  description = "Azure VNet settings"
  default = {
    "default" = {
      cidr        = ["10.128.0.0/20"]
      subnet_cidr = "10.128.0.0/24"
    },
    "dev" = {
      cidr        = ["10.128.0.0/20"]
      subnet_cidr = "10.128.0.0/24"
    },
    "test" = {
      cidr        = ["10.128.0.0/20"]
      subnet_cidr = "10.128.0.0/24"
    },
    "prod" = {
      cidr        = ["10.128.0.0/20"]
      subnet_cidr = "10.128.0.0/24"
    },
    "cat" = {
      cidr        = ["10.128.0.0/20"]
      subnet_cidr = "10.128.0.0/24"
    }
  }
}

# Passsword for Windows:
# The supplied password must be between 8-123 characters long and must satisfy at least 3 of password complexity requirements
# from the following:
# 1) Contains an uppercase character
# 2) Contains a lowercase character
# 3) Contains a numeric digit
# 4) Contains a special character
# 5) Control characters are not allowed

variable azure_vm {
  type = map(object({
    name              = string
    vm_type           = string
    vm_admin_account  = string
    vm_admin_password = string
    vm_ssh_key        = string
    vm_tags           = map(string)
  }))
  description = "Azure VNet settings"
  default = {
    "test-linux" = {
      name              = "vm-dev-test-vm"
      vm_type           = "Standard_A3"
      vm_admin_account  = "ojala"
      vm_admin_password = ""
      vm_ssh_key        = "~/.ssh/id_rsa.pub"
      vm_tags = {
        ansible_group = "linux"
      }
    },
    "test-windows" = {
      name              = "windows1"
      vm_type           = "Standard_A3"
      vm_admin_account  = "ojala"
      vm_admin_password = "FOOfoo#123"
      vm_ssh_key        = ""
      vm_tags = {
        ansible_group = "windows"
      }
    }
  }
}

locals {
  azure_environment = var.azure_environment[terraform.workspace]
  azure_vnet        = var.azure_vnet[terraform.workspace]
}
