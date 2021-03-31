# The key vault will be restored if it has been soft deleted.
resource "azurerm_key_vault" "kv" {
  name                        = "cpw-disk-vault"
  location                    = azurerm_resource_group.kv-rg.location
  resource_group_name         = azurerm_resource_group.kv-rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "me" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "get",
    "create",
    "delete",
    "list",
    "recover",
    "restore",
    "purge"
  ]
}

# Here are the key and policy resources for the Linux VM
resource "azurerm_key_vault_key" "kek-lx" {
  name         = "${var.prefix}-kek-lx"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

   depends_on = [
    azurerm_key_vault_access_policy.me
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "cryptset-lx" {
  name                = "${var.prefix}-cryptset-lx"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  key_vault_key_id    = azurerm_key_vault_key.kek-lx.id

  identity {
    type = "SystemAssigned"
  }
}

# Grant access from the disk encryption set to the keyvault
resource "azurerm_key_vault_access_policy" "kvpol-lx" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = azurerm_disk_encryption_set.cryptset-lx.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.cryptset-lx.identity.0.principal_id

  key_permissions = [
    "get",
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# Here are the policy resources for the Windows VM
resource "azurerm_key_vault_key" "kek-wn" {
  name         = "${var.prefix}-kek-wn"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  depends_on = [
    azurerm_key_vault_access_policy.me
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "cryptset-wn" {
  name                = "${var.prefix}-cryptset-wn"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  key_vault_key_id    = azurerm_key_vault_key.kek-wn.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "kvpol-wn" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = azurerm_disk_encryption_set.cryptset-wn.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.cryptset-wn.identity.0.principal_id

  key_permissions = [
    "get",
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}