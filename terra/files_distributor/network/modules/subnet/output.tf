# Subnet output

output "hatchery_sbn_public_id" {
  value = aws_subnet.sbn_hatchery_public.id
}
output "hatchery_sbn_private_id" {
  value = aws_subnet.sbn_hatchery_private.id
}
