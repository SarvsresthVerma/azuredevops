terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.34.0"
    }
  }
}

provider "azurerm" {
  features {}
subscription_id = "45d2c8fb-faba-4dc1-ab43-5ad9451eef1c"
}