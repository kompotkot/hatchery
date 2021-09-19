# Security Group output

output "hatchery_security_group_id" {
  value = aws_security_group.hatchery_sg.id
}
