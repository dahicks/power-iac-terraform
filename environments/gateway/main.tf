module "network" {
    source = "../../modules/network"
    project = var.project
    regions = var.regions
    name = var.name
}

resource "google_service_account" "demo" {
  account_id   = "svc-demo"
  display_name = "demo Service Account"
}

module "upstream" {
  source = "../../modules/upstream"

  for_each = var.regions
  project = var.project
  network = module.network.network_details.network
  subnetwork = module.network.network_details.subnets[each.key]
  service_account = google_service_account.demo.email
  region = each.key  
  name = var.name
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
  upstream = {
    address = module.upstream[each.key].echo_ip_address  
    port = 3000
  }
}

module "loadbalancer" {
  source = "../../modules/loadbalancer"
  instance_groups = local.instance_groups
}
