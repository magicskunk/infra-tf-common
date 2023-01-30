output "container_repositories" {
  description = "Urls to provisioned container repositories"
  value       = module.container_repository.repositories
}

output "nat_gateway_public_ip" {
  value = module.vpc.nat_gateway_public_ip
}

output "nat_gateway_public_ip_cidr_block" {
  value = module.vpc.nat_gateway_public_ip_cidr_block
}
