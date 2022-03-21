variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "name" {
  default = "todomysql"
  description = "The name of the MySQL deployment"
}
variable "namespace" {
  default = "todo"
  description = "The kubernetes namespace to run the mysql server in."
}

variable "selectors" {
  type = map(string)
  default = {}
}

variable "labels" {
  type = map(string)
  default = {}
}

variable "mysql_storage_size" {
  default = "1Gi"
  description = "The storage size of the PVC, for example: 10Gi"
}

variable "mysql_image_url" {
  default = "mysql"
  description = "The image url of the mysql version wanted, found via https://hub.docker.com/_/mysql"
}

variable "mysql_image_tag" {
  default = "5.7"
  description = "The image tag of the mysql version wanted, found via https://hub.docker.com/_/mysql"
}

variable "mysql_requests" {
  description = "The k8s cpu/memory requests for the mysql server."
  default = {
    cpu = "100m"
    memory = "128Mi"
  }
}

variable "mysql_limits" {
  description = "The k8s cpu/memory limits for the mysql server."
  default = {}
}

variable "mysql_storage_class" {
  description = "The k8s storage class for the PVC used."
  default = "premium-rwo"
}

variable "mysql_storage_persistent_volume_reclaim_policy" {
  default = "Retain"
}

variable "mysql_user" {
    default = "gkemysqluser"
  description = "The name of the mysql user, also used as the name of the initial database."
}