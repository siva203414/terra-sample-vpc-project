variable "region" {
  type = string
}
variable "db_engine" {
  type = string
}
variable "db_instance_class" {
  type = string
}
variable "db_instance_name" {
  type = string
}
variable "db_engine_version" {
  type = string
}
variable "db_engine_pggroup" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_password" {
  type = string
}
variable "allocate_storage" {
  type = number
}
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "db_backup_retention_period" {
  type = number
}
variable "db_backup_window" {
  type = string
}
variable "db_maintenence_period" {
  type = string
}
