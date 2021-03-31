# The Linux virtual machine will be created with SSE/CMK
# See https://docs.microsoft.com/en-us/azure/virtual-machines/disk-encryption#customer-managed-keys

resource "azurerm_linux_virtual_machine" "vmlinux" {
  name                  = "${var.prefix}-linux"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.lx-nic.id]
  size                  = "Standard_B2ms"
  admin_username        = "azureuser"

  admin_ssh_key {
      username = "azureuser"
      public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching       = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_encryption_set_id = azurerm_disk_encryption_set.cryptset-lx.id
  }
}

# The Windows VM will be created with an Azure Disk Encryption (ADE) OS volume
# See https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption-overview
resource "azurerm_windows_virtual_machine" "vmwindows" {
  name                = "${var.prefix}-windows"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.wn-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    # the following is DISABLED to allow Azure Disk Encryption (ADE) instead
    # disk_encryption_set_id = azurerm_disk_encryption_set.cryptset-wn.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# resource "azurerm_virtual_machine_extension" "vmextensionlinux" {
#  name                       = "DiskEncryption"
#  virtual_machine_id         = azurerm_linux_virtual_machine.vmlinux.id
#  publisher                  = "Microsoft.Azure.Security"
#  type                       = "AzureDiskEncryptionForLinux"
#  type_handler_version       = "1.1"
#  auto_upgrade_minor_version = true
#  tags = var.tags
  
#  settings = <<SETTINGS
#    {
#        "EncryptionOperation": "EnableEncryption",
#        "KeyVaultURL": "${azurerm_key_vault.kv.vault_uri}",
#        "KeyVaultResourceId": "${azurerm_key_vault.kv.id}",					
#        "KeyEncryptionKeyURL": "${azurerm_key_vault.kv.vault_uri}/keys/${azurerm_key_vault_key.kek-lx.name}",
#        "KekVaultResourceId": "${azurerm_key_vault.kv.id}",
#        "KeyEncryptionAlgorithm": "RSA-OAEP",
#        "VolumeType": "All"
#    }
#SETTINGS
# 
#}

resource "azurerm_virtual_machine_extension" "vmextensionwindows" {
  name                       = "DiskEncryption"
  virtual_machine_id         = azurerm_windows_virtual_machine.vmwindows.id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryption"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = true
  
  
  settings = <<SETTINGS
    {
        "EncryptionOperation": "EnableEncryption",
        "KeyVaultURL": "${azurerm_key_vault.kv.vault_uri}",
        "KeyVaultResourceId": "${azurerm_key_vault.kv.id}",					
        "KeyEncryptionKeyURL": "${azurerm_key_vault_key.kek-wn.id}",
        "KekVaultResourceId": "${azurerm_key_vault.kv.id}",
        "KeyEncryptionAlgorithm": "RSA-OAEP",
        "VolumeType": "All"
    }
SETTINGS
  
  tags = var.tags

}