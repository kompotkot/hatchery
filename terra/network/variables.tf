# Predifined variables for resources

# Main
variable "region" {
  description = "The region that the machine should be created in"
  default     = "us-east-1"
}
variable "tag_resource" {
    default = "hatchery"
}

# VPC
variable "vpc_name" {
    default = "vpc_hatchery"
}
variable "vpc_cidr_block" {
    description = "VPC IPv4 address range"
    default = "10.0.0.0/16"
}
variable "sbn_name_public" {
    default = "sbn_hatchery_public"
}
variable "sbn_cidr_block_public" {
    description = "Subnet IPv4 address range"
    default = "10.0.11.0/24"
}
variable "sbn_name_private" {
    default = "sbn_hatchery_private"
}
variable "sbn_cidr_block_private" {
    description = "Subnet IPv4 address range"
    default = "10.0.21.0/24"
}

variable "igw_name" {
    default = "igw_hatchery"
}
variable "ngw_name" {
    default = "ngw_hatchery"
}

variable "rt_name_public" {
    default = "rt_hatchery_public"
}
variable "rt_name_private" {
    default = "rt_hatchery_private"
}
