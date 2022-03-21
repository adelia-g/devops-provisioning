locals {
  labels = merge(var.labels, {
    app = "mysql-server"
    deploymentName = var.name
  })

  selectors = merge(var.selectors, {
    app = "mysql-server"
    deploymentName = var.name
  })
}

resource "random_string" "mysql_root_password" {
  length = 16
  special = false
}

resource "random_string" "mysql_password" {
  length = 16
  special = false
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
# Retrieve an access token as the Terraform runner
data "google_client_config" "provider" {}

data "google_container_cluster" "my_cluster" {
  name     = "todo-project-344814-gke"
  location = "us-central1"
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "${var.name}-mysql-server"
    namespace = var.namespace
    labels = local.labels
  }

  spec {
    selector {
      match_labels = local.selectors
    }

    template {
      metadata {
        name = "mysql"
        labels = local.labels
      }

      spec {
        volume {
          name = "storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql.metadata[0].name
          }
        }

        container {
          name = "mysql"
          image = "${var.mysql_image_url}:${var.mysql_image_tag}"

          port {
            container_port = 3306
          }

          resources {
            requests = var.mysql_requests
            limits = var.mysql_limits
          }

          volume_mount {
            mount_path = "/var/lib/mysql"
            name = "storage"
            sub_path = "mysql"
          }

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value = random_string.mysql_root_password.result
          }

          env {
            name = "MYSQL_USER"
            value = var.mysql_user
          }

          env {
            name = "MYSQL_PASSWORD"
            value = random_string.mysql_password.result
          }

          env {
            name = "MYSQL_DATABASE"
            value = var.mysql_user
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name = "${var.name}-mysql-server"
    namespace = var.namespace
  }

  spec {
    port {
      port = 3306
      target_port = 3306
    }

    selector = local.selectors

    type = "ClusterIP"
  }
}

resource "kubernetes_persistent_volume_claim" "mysql" {
  metadata {
    name = "${var.name}-mysql-server"
    namespace = var.namespace
  }
  spec {
    storage_class_name = var.mysql_storage_class
    access_modes = [
      "ReadWriteOnce"
    ]
    resources {
      requests = {
        storage = var.mysql_storage_size
      }
    }
  }
}