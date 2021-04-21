output "echo_ip_address" {
  value = { for k,v in var.regions : k => module.upstream[k].echo_ip_address }
}

output "load_balancer" {
  value = module.loadbalancer.load_balancer_ip
}