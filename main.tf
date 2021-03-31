# Configure the Microsoft Azure Provider.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {

}

# Create a resource group for all the resources
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

# Create a resource group for the key vault
resource "azurerm_resource_group" "kv-rg" {
  name     = "${var.prefix}-kv-rg"
  location = var.location
  tags     = var.tags
}
