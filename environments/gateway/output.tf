output "upstream_internal_addresses" {
  value = { for k,v in var.regions : k => module.upstream[k].upstream_ip_address }
}

output "load_balancer" {
  value = module.loadbalancer.load_balancer_ip
}