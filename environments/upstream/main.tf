module "network" {
    source = "../../modules/network"
    project = var.project
    regions = var.regions
    name = var.name
}

resource "google_service_account" "demo" {
  account_id   = "svc-demo-${var.name}"
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

output "echo_ip_address" {
  value = { for k,v in var.regions : k => module.upstream[k].echo_ip_address }
}