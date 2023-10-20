# resource "azurerm_mssql_server" "petclinic" {
#   name                         = "petclinic-sqlserver"
#   resource_group_name          = azurerm_resource_group.rg.name
#   location                     = azurerm_resource_group.rg.location
#   version                      = "12.0"
#   administrator_login          = "petclinic"
#   administrator_login_password = "19952012dD!"
# }

# resource "azurerm_mssql_database" "test" {
#   name           = "acctest-db-d"
#   server_id      = azurerm_mssql_server.petclinic.id
#   collation      = "SQL_Latin1_General_CP1_CI_AS"
#   license_type   = "LicenseIncluded"
#   max_size_gb    = 4
#   read_scale     = false
#   sku_name       = "S0"
#   zone_redundant = false

#   tags = {
#     Terraform = "true"
#   }
# }



resource "helm_release" "nginx_ingress" {
  name       = "mysql"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  namespace  = "mysql"
  set {
    name  = "auth.database"
    value = "petclinic"
  }
}