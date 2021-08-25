# Security Group main

resource "aws_security_group" "hatchery_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.hatchery_vpc_id

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Product = var.tag_resource
    Role    = "server"
  }
}
