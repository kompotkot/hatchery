provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "vpc_hatchery" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name     = var.vpc_name
    Resource = var.tag_resource
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw_hatchery" {
  vpc_id = aws_vpc.vpc_hatchery.id

  tags = {
    Name     = var.igw_name
    Resource = var.tag_resource
  }
}

# Subnets
resource "aws_subnet" "sbn_hatchery_public" {
  vpc_id     = aws_vpc.vpc_hatchery.id
  cidr_block = var.sbn_cidr_block_public

  map_public_ip_on_launch = true

  tags = {
    Name     = var.sbn_name_public
    Resource = var.tag_resource
    Access   = "public"
  }
}
resource "aws_subnet" "sbn_hatchery_private" {
  vpc_id     = aws_vpc.vpc_hatchery.id
  cidr_block = var.sbn_cidr_block_private

  tags = {
    Name     = var.sbn_name_private
    Resource = var.tag_resource
    Access   = "private"
  }
}

# Elastic IP
resource "aws_eip" "eip_nat_hatchery" {
  vpc = true
}

# NAT gateway
resource "aws_nat_gateway" "ngw_hatchery" {
  allocation_id = aws_eip.eip_nat_hatchery.id
  subnet_id     = aws_subnet.sbn_hatchery_public.id

  tags = {
    Name     = var.ngw_name
    Resource = var.tag_resource
  }
}

# Route table (public)
resource "aws_route_table" "rt_hatchery_public" {
  vpc_id = aws_vpc.vpc_hatchery.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_hatchery.id
  }

  tags = {
    Name     = var.rt_name_public
    Resource = var.tag_resource
    Access   = "public"
  }
}
resource "aws_route_table_association" "rt_a_hatchery_public" {
  subnet_id      = aws_subnet.sbn_hatchery_public.id
  route_table_id = aws_route_table.rt_hatchery_public.id
}

# Route table (private)
resource "aws_route_table" "rt_hatchery_private" {
  vpc_id = aws_vpc.vpc_hatchery.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_hatchery.id
  }

  tags = {
    Name     = var.rt_name_private
    Resource = var.tag_resource
    Access   = "private"
  }
}

resource "aws_route_table_association" "rt_a_hatchery_private" {
  subnet_id      = aws_subnet.sbn_hatchery_private.id
  route_table_id = aws_route_table.rt_hatchery_private.id
}
