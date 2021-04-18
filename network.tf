resource "google_compute_network" "demo" {
  name                    = "demo"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "demo" {
  for_each = var.regions
  name          = "demo-${each.key}"
  ip_cidr_range = each.value.cidr
  region        = each.key
  network       = google_compute_network.demo.id
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  for_each = var.regions
  name    = "demo"
  region  = google_compute_subnetwork.demo[each.key].region
  network = google_compute_network.demo.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  for_each = var.regions
  name                               = "demo"
  router                             = google_compute_router.router[each.key].name
  region                             = google_compute_router.router[each.key].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}