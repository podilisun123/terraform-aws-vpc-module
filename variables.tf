## Project
variable "projct_name" {
    type = string
}
variable "environment" {
    type = string
}
variable "common_tags" {
    type = map
}
## vpc 
variable "vpc_cidr" {
    type = string
    default =  "10.0.0.0/16"
}
variable "enable_dns_hostnames" {
    type = bool
    default = true
}
variable "vpc_tags" {
    type = map
    default = {}
}
## igw 
variable "igw_tags" {
    type = map
    default = {}
}
## public subnet
variable "public_subnet_dirs" {
    type = list
    validation {
        condition     = length(var.public_subnet_dirs) == 2
        error_message = "Please give 2 valid public subnet dirs"
    }
}
variable "public_subnet_tags" {
    type = map
    default = {}
}
## private subnet
variable "private_subnet_dirs" {
    type = list
    validation {
        condition     = length(var.private_subnet_dirs) == 2
        error_message = "Please give 2 valid private subnet dirs"
    }
}
variable "private_subnet_tags" {
    type = map
    default = {}
}
## database subnet
variable "database_subnet_dirs" {
    type = list
    validation {
        condition     = length(var.database_subnet_dirs) == 2
        error_message = "Please give 2 valid database subnet dirs"
    }
}
variable "database_subnet_tags" {
    type = map
    default = {}
}
variable "database_subnet_group_tags" {
    type = map
    default = {}
}
## ngw 
variable "ngw_tags" {
    type = map
    default = {}
}
## route tables
variable "public_route_table_tags" {
    type = map
    default = {}
}
variable "private_route_table_tags" {
    type = map
    default = {}
}
variable "database_route_table_tags" {
    type = map
    default = {}
}
variable "is_peering_required" {
    type = bool
    default = false
}
variable "acceptro_vpc" {
    type = string
    default = ""
}
variable "peering_tags" {
    type = map
    default = {}
}