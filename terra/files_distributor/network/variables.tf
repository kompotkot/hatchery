# Main variables

variable "region" {
  description = "The region that the machine should be created in"
  default     = "us-east-1"
}
variable "tag_resource" {
  description = "Resource common tag"
  default     = "hatchery"
}

# VPC
variable "vpc_cidr_block" {
  description = "VPC IPv4 address range"
  default     = "10.0.0.0/16"
}
variable "vpc_name" {
  default = "hatchery_vpc"
}

# Internet gateway
variable "igw_name" {
  default = "hatchery_igw"
}

# Subnet
variable "sbn_cidr_block_public_a" {
  description = "Subnet IPv4 address range"
  default     = "10.0.11.0/24"
}
variable "sbn_name_public_a" {
  default = "sbn_hatchery_public_a"
}
variable "sbn_cidr_block_public_b" {
  description = "Subnet IPv4 address range"
  default     = "10.0.12.0/24"
}
variable "sbn_name_public_b" {
  default = "sbn_hatchery_public_b"
}
variable "sbn_cidr_block_private_a" {
  description = "Subnet IPv4 address range"
  default     = "10.0.21.0/24"
}
variable "sbn_name_private_a" {
  default = "sbn_hatchery_private_a"
}

# NAT Gateway
variable "ngw_name" {
  default = "hatchery_ngw"
}

# Route table
variable "rt_name_public" {
  default = "hatchery_rt_public"
}
variable "rt_name_private" {
  default = "hatchery_rt_private"
}
