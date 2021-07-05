# Main variables

variable "region" {
  description = "The region that the machine should be created in"
  default     = "us-east-1"
}
variable "tag_resource" {
  description = "Resource common tag"
  default     = "hatchery"
}

variable "hatchery_vpc_id" {}

# Security Group
variable "sg_name" {
  default = "hatchery-files-distributor-sg"
}
variable "sg_description" {
  default = "Lambda files distributor Security Group"
}

# Load Balancer
variable "lb_name" {
  default = "hatchery-files-distributor-lb"
}
variable "hatchery_sbn_public_id" {}
variable "hatchery_lambda_arn" {}
