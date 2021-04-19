# allow health check firewall rules
# required so that Google Load Balancer can perform healthcheck on backend instances
resource "google_compute_firewall" "demo" {
  name = "fw-allow-health-check"
  network = google_compute_network.demo.self_link
  allow {
    protocol = "tcp"
    ports = ["10000"]
  }
  target_tags = [ "fw-allow-health-check" ]
  source_ranges = [ "130.211.0.0/22","35.191.0.0/16" ]
}

# Firewall to permit SSH traffic over IAP
resource "google_compute_firewall" "demo-iap-ssh" {
  name = "fw-allow-iap-ssh"
  network = google_compute_network.demo.self_link
  allow {
    protocol = "tcp"
  }  
  source_ranges = [ "35.235.240.0/20" ]
}


# create custom network
resource "google_compute_network" "demo" {
  name                    = "demo"
  auto_create_subnetworks = false
}

# create subnets based on regions variable
resource "google_compute_subnetwork" "demo" {
  for_each = var.regions
  name          = "demo-${each.key}"
  ip_cidr_range = each.value.cidr
  region        = each.key
  network       = google_compute_network.demo.id
  private_ip_google_access = true
}

# router / nat required for nodes without external IP address to get out to internet
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