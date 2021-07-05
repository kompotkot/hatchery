# Route table main

resource "aws_route_table" "rt_hatchery_public" {
  vpc_id = var.hatchery_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name     = var.rt_name_public
    Resource = var.tag_resource
    Access   = "public"
  }
}

resource "aws_route_table_association" "rt_a_hatchery_public_a" {
  subnet_id      = var.hatchery_sbn_public_a_id
  route_table_id = aws_route_table.rt_hatchery_public.id
}
resource "aws_route_table_association" "rt_a_hatchery_public_b" {
  subnet_id      = var.hatchery_sbn_public_b_id
  route_table_id = aws_route_table.rt_hatchery_public.id
}

resource "aws_route_table" "rt_hatchery_private" {
  vpc_id = var.hatchery_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.nat_gateway_id
  }

  tags = {
    Name     = var.rt_name_private
    Resource = var.tag_resource
    Access   = "private"
  }
}

resource "aws_route_table_association" "rt_a_hatchery_private_a" {
  subnet_id      = var.hatchery_sbn_private_a_id
  route_table_id = aws_route_table.rt_hatchery_private.id
}
