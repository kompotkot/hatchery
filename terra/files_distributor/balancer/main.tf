# Main
# Load Balancer, Security group for 
# file destribution infrastructure

provider "aws" {
  region = var.region
}

module "security_group" {
  source = "./modules/security_group"

  sg_name        = var.sg_name
  sg_description = var.sg_description
  tag_resource   = var.tag_resource

  hatchery_vpc_id = var.hatchery_vpc_id
}

module "load_balancer" {
  source = "./modules/load_balancer"

  lb_name      = var.lb_name
  tag_resource = var.tag_resource

  hatchery_lambda_arn        = var.hatchery_lambda_arn
  hatchery_sbn_public_id     = var.hatchery_sbn_public_id
  hatchery_security_group_id = module.security_group.hatchery_security_group_id
}
