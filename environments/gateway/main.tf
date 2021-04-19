module "network" {
    source = "../../modules/network"
    project = var.project
    regions = var.regions
}

resource "google_service_account" "demo" {
  account_id   = "svc-demo"
  display_name = "demo Service Account"
}

module "gateway" {
  source = "../../modules/gateway"

  for_each = var.regions
  project = var.project
  network = module.network.network_details.network
  subnetwork = module.network.network_details.subnets[each.key]
  service_account = google_service_account.demo.email
  region = each.key
  name = var.name
}

module "loadbalancer" {
  source = "../../modules/loadbalancer"
  instance_groups = [ for k,v in var.regions: module.gateway[k].instance_groups ]
}

output "instance_groups" {
  value = { for k,v in var.regions: k => module.gateway[k].instance_groups }
}

output "load_balancer" {
  value = module.loadbalancer.load_balancer_ip
}