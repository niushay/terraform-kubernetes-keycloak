variable "postgres_db" { default = "db_name" }

variable "postgres_username" { default = "db_username" }

variable "postgres_password" { default = "db_password" }

variable "postgres_pvc_storage" { default = "1Gi" }

variable "keycloak_user" { default = "amdin" }

variable "keycloak_password" { default = "admin" }

variable "keycloak_realm" { default = "myrealm" }

variable "keycloak_import" { default = "/tmp/realm.json" }

