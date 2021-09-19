# VPC output

output "hatchery_vpc_id" {
  value = aws_vpc.hatchery_vpc.id
}
output "hatchery_internet_gateway_id" {
  value = aws_internet_gateway.hatchery_igw.id
}
