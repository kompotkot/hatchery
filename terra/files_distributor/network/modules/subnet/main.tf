# Subnet main

resource "aws_subnet" "sbn_hatchery_public" {
  vpc_id     = var.vpc_id
  cidr_block = var.sbn_cidr_block_public

  map_public_ip_on_launch = true

  tags = {
    Name     = var.sbn_name_public
    Resource = var.tag_resource
    Access   = "public"
  }
}

resource "aws_subnet" "sbn_hatchery_private" {
  vpc_id     = var.vpc_id
  cidr_block = var.sbn_cidr_block_private

  tags = {
    Name     = var.sbn_name_private
    Resource = var.tag_resource
    Access   = "private"
  }
}
