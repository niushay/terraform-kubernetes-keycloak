resource "kubernetes_config_map" "keycloak_config" {
  metadata {
    name = "keycloak-config"
  }
  data = {
    KEYCLOAK_USER     = var.keycloak_user
    KEYCLOAK_PASSWORD = var.keycloak_password
    KEYCLOAK_REALM    = var.keycloak_realm
    KEYCLOAK_IMPORT   = var.keycloak_import
  }
}

resource "kubernetes_secret" "postgresql_credentials" {
  metadata {
    name = "postgresql-credentials"
  }
  data = {
    POSTGRES_DB       = var.postgres_db
    POSTGRES_USER     = var.postgres_username
    POSTGRES_PASSWORD = var.postgres_password
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name = "postgres-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.postgres_pvc_storage
      }
    }
  }
}

resource "kubernetes_stateful_set" "postgresql" {
  metadata {
    name = "postgresql"
  }
  spec {
    service_name = "postgresql"
    replicas     = 1

    selector {
      match_labels = {
        app = "postgresql"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgresql"
        }
      }

      spec {
        container {
          name  = "postgresql"
          image = "postgres:latest"

          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_credentials.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_credentials.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_credentials.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          port {
            container_port = 5432
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = "postgres-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgresql" {
  metadata {
    name = "postgresql"
  }
  spec {
    selector = {
      app = "postgresql"
    }
    port {
      protocol    = "TCP"
      port        = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_deployment" "keycloak" {
  metadata {
    name = "keycloak"
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "keycloak"
      }
    }

    template {
      metadata {
        labels = {
          app = "keycloak"
        }
      }

      spec {
        container {
          name  = "keycloak"
          image = "quay.io/keycloak/keycloak:latest"

          env {
            name = "KEYCLOAK_USER"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak_config.metadata[0].name
                key  = "KEYCLOAK_USER"
              }
            }
          }
          env {
            name = "KEYCLOAK_PASSWORD"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak_config.metadata[0].name
                key  = "KEYCLOAK_PASSWORD"
              }
            }
          }
          env {
            name = "KEYCLOAK_REALM"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak_config.metadata[0].name
                key  = "KEYCLOAK_REALM"
              }
            }
          }
          env {
            name  = "DB_VENDOR"
            value = "POSTGRES"
          }
          env {
            name  = "DB_ADDR"
            value = "postgresql"
          }
          env {
            name  = "DB_PORT"
            value = "5432"
          }
          env {
            name = "DB_DATABASE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_credentials.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }
          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_credentials.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }
          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_credentials.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "keycloak" {
  metadata {
    name = "keycloak"
  }
  spec {
    selector = {
      app = "keycloak"
    }
    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }
  }
}
