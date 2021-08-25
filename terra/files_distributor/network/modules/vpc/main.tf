# VPC main

resource "aws_vpc" "hatchery_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name     = var.vpc_name
    Resource = var.tag_resource
  }
}

# Internet gateway
resource "aws_internet_gateway" "hatchery_igw" {
  vpc_id = aws_vpc.hatchery_vpc.id

  tags = {
    Name     = var.igw_name
    Resource = var.tag_resource
  }
}
