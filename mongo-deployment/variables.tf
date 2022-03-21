variable "namespace" {
  default = "todo"
  description = "The kubernetes namespace to run the mongodb server in."
}
variable "name" {
  default = "todomongodb"
  description = "The name of the MySQL deployment"
}
variable "replicacount" {}
variable "storage_size" {
  default = "2Gi"
}
variable "storage_class_name" {
  default = "standard"
}
variable "request_cpu" {
  default = "250m"
}
variable "request_mem" {
  default = "1Gi"
}
variable "limit_cpu" {
  default = "1"
}
variable "limit_mem" {
  default = "2Gi"
}
