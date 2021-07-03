# Main
# Load Balancer, Security group for 
# file destribution infrastructure

provider "aws" {
  region = var.region
}

module "security_group" {
  source = "./modules/security_group"
}

module "load_balancer" {
  source = "./modules/load_balancer"
}
