terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-rg"
    storage_account_name  = "terraformstrorage29876"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}