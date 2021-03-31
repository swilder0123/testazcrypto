# Test Azure VM Encryption Types
This project deploys the following resources in an Azure subscription:

1. Two resource groups:
-- A "Key Vault" resource group, <name>-kv-rg
-- A "VM" resource group, <name>-rg

2. Two VM's:
-- A Linux VM with Azure server-side encryption enabled using a customer-managed key for the OS volume
-- A Windows VM with Azure Key Encryption enabled for the OS volume

3. A virtual network to connect the virtual machines

4. An Azure Key Vault to store key encryption keys to securely support the above disk encryption

