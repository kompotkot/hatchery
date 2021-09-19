# Main
# VPC, Gateway, Subnets, Route tables,
# Elastic IP for file destribution infrastructure

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  vpc_name       = var.vpc_name
  tag_resource   = var.tag_resource

  igw_name = var.igw_name
}

# Subnets
module "subnet" {
  source = "./modules/subnet"

  vpc_id = module.vpc.hatchery_vpc_id

  sbn_cidr_block_public_a  = var.sbn_cidr_block_public_a
  sbn_name_public_a        = var.sbn_name_public_a
  sbn_cidr_block_public_b  = var.sbn_cidr_block_public_b
  sbn_name_public_b        = var.sbn_name_public_b
  sbn_cidr_block_private_a = var.sbn_cidr_block_private_a
  sbn_name_private_a       = var.sbn_name_private_a

  tag_resource = var.tag_resource
}

# Elastic IP
resource "aws_eip" "eip_nat_hatchery" {
  vpc = true
}

# NAT gateway
resource "aws_nat_gateway" "ngw_hatchery" {
  allocation_id = aws_eip.eip_nat_hatchery.id
  subnet_id     = module.subnet.hatchery_sbn_public_a_id

  tags = {
    Name     = var.ngw_name
    Resource = var.tag_resource
  }
}

# Route table
module "route_table" {
  source = "./modules/route_table"

  hatchery_vpc_id     = module.vpc.hatchery_vpc_id
  internet_gateway_id = module.vpc.hatchery_internet_gateway_id
  nat_gateway_id      = aws_nat_gateway.ngw_hatchery.id

  rt_name_public  = var.rt_name_public
  rt_name_private = var.rt_name_private

  hatchery_sbn_public_a_id  = module.subnet.hatchery_sbn_public_a_id
  hatchery_sbn_public_b_id  = module.subnet.hatchery_sbn_public_b_id
  hatchery_sbn_private_a_id = module.subnet.hatchery_sbn_private_a_id

  tag_resource = var.tag_resource
}
