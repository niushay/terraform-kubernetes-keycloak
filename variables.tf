variable "postgres_db" {
  type        = string
  description = "This is database name"
}
variable "postgres_username" {
  type        = string
  description = "This is database username"

}
variable "postgres_password" {
  type        = string
  description = "This is database password"
}
variable "postgres_pvc_storage" {
  type        = string
  description = "This is amount of persistent volume claim of postgresql storage"
}
variable "keycloak_user" {
  type        = string
  description = "This is username of keycloak"
}
variable "keycloak_password" {
  type        = string
  description = "This is password of keycloak"
}
variable "keycloak_realm" {
  type        = string
  description = "This is realm of keycloak"
}
variable "keycloak_import" {
  type        = string
  description = "This is import path of keycloak"
}
