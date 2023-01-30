output "nat_gateway_public_ip" {
  value = aws_nat_gateway.main.public_ip
}

output "nat_gateway_public_ip_cidr_block" {
  value = format("%s%s", aws_nat_gateway.main.public_ip, "/32")
}
