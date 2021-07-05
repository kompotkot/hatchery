# Subnet output

output "hatchery_sbn_public_a_id" {
  value = aws_subnet.sbn_hatchery_public_a.id
}
output "hatchery_sbn_public_b_id" {
  value = aws_subnet.sbn_hatchery_public_b.id
}
output "hatchery_sbn_private_a_id" {
  value = aws_subnet.sbn_hatchery_private_a.id
}
