output "instance_groups" {
  value = { for k,v in var.regions: k => module.gateway[k].instance_groups }
}

output "load_balancer" {
  value = module.loadbalancer.load_balancer_ip
}