resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "kpn"
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# data "azurerm_image" "debian" {
#   name_regex          = "Debian.+"
#   resource_group_name = "packerimages"
# }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "jenkins_vm" {
  name                  = "Jenkins-instance"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
#   source_image_id = data.azurerm_image.debian

  computer_name  = "jenkins"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDhjaU+J6mZ1OrCGcGJkhIcEdMpvEH9Px5qynVHQQEAFGgWzJtac32nZt/DcfU0AIKtinlaUxUlGQ2rFoYWxC8oLKyqXmd0feQ1ta1Rx7Kt5KCqx1Dc40E7KeQuA3fBKOGxElGgOhOfwja/IsuTkrU5W/c/YHYCqldOdO8STgxJ5fNXJJh3OdH3RcgT4tShimgl+WVdcOyjT6MIs24ZnHdvhAh3PYs2htzm7Q/xaztGo1GIDJVm5nA88dgksdM9vlQtK+aWKCzZ1H89cwrYhUbyMT9MwajoSP3gUz08XPiI/PgJyLF1KfGoXOpUVFVM6rMsoRusAUAVCTC6OkuLaCEbYXjCtL6Cd9LW5Tr7r84uV+8VtaPB5yBg0y0SIdZk2fl5YtpAaY6N3sgkSvaNPAa666QLxybsBOg8WoGLjNuAaKtsvGRpOnFTYarQDYwFCW4EdnIIz/paOYG2voKkvli6oiPPBIjqLovCSgz4mSrM90YdT2nhm0Xb0FN932ps7yE= sylar@sylar-pc"
    # jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage_account.primary_blob_endpoint
  }

  user_data = "IyEvYmluL2Jhc2gKd2dldCAtcSAtTyAtIGh0dHBzOi8vcGtnLmplbmtpbnMuaW8vZGViaWFuLXN0YWJsZS9qZW5raW5zLmlvLmtleSB8c3VkbyBncGcgLS1kZWFybW9yIC1vIC91c3Ivc2hhcmUva2V5cmluZ3MvamVua2lucy5ncGcKc3VkbyBzaCAtYyAnZWNobyBkZWIgW3NpZ25lZC1ieT0vdXNyL3NoYXJlL2tleXJpbmdzL2plbmtpbnMuZ3BnXSBodHRwOi8vcGtnLmplbmtpbnMuaW8vZGViaWFuLXN0YWJsZSBiaW5hcnkvID4gL2V0Yy9hcHQvc291cmNlcy5saXN0LmQvamVua2lucy5saXN0JwpzdWRvIGFwdCB1cGRhdGUKc3VkbyBhcHQgaW5zdGFsbCBqZW5raW5zCnN1ZG8gc3lzdGVtY3RsIGVuYWJsZSBqZW5raW5zLnNlcnZpY2UKc3VkbyBzeXN0ZW1jdGwgc3RhcnQgamVua2lucy5zZXJ2aWNl"
    
}

