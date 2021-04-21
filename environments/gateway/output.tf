output "load_balancer" {
  value = module.loadbalancer.load_balancer_ip
}

output "subnetwork_ranges" {  value = var.regions }