# Subnet main

resource "aws_subnet" "sbn_hatchery_public_a" {
  vpc_id     = var.vpc_id
  cidr_block = var.sbn_cidr_block_public_a

  map_public_ip_on_launch = true

  tags = {
    Name     = var.sbn_name_public_a
    Resource = var.tag_resource
    Access   = "public"
  }
}

resource "aws_subnet" "sbn_hatchery_public_b" {
  vpc_id     = var.vpc_id
  cidr_block = var.sbn_cidr_block_public_b

  map_public_ip_on_launch = true

  tags = {
    Name     = var.sbn_name_public_b
    Resource = var.tag_resource
    Access   = "public"
  }
}

resource "aws_subnet" "sbn_hatchery_private_a" {
  vpc_id     = var.vpc_id
  cidr_block = var.sbn_cidr_block_private_a

  tags = {
    Name     = var.sbn_name_private_a
    Resource = var.tag_resource
    Access   = "private"
  }
}
