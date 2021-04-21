resource "google_compute_address" "upstream" {
  name         = "upstream-internal"
  region       = var.region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  subnetwork   = var.subnetwork
}
resource "google_compute_forwarding_rule" "upstream" {
  all_ports             = false
  allow_global_access   = true
  backend_service       = google_compute_region_backend_service.upstream.id
  ip_address            = google_compute_address.upstream.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  name                  = "${var.name}-internal-tcp"
  network               = var.network
  network_tier          = "PREMIUM"
  ports = [
    "3000"
  ]
  region     = var.region
  subnetwork = var.subnetwork
  timeouts {}
}
resource "google_compute_health_check" "upstream" {
  name                = "echo-hc-${var.region}"
  check_interval_sec  = 15
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {    
    port = "3000"
  }
}
resource "google_compute_region_backend_service" "upstream" {
  affinity_cookie_ttl_sec         = 0
  connection_draining_timeout_sec = 300
  health_checks                   = [google_compute_health_check.upstream.id]
  load_balancing_scheme           = "INTERNAL"
  name                            = "upstream-internal"
  protocol                        = "TCP"
  region                          = var.region
  session_affinity                = "NONE"
  timeout_sec                     = 30
  backend {
    balancing_mode               = "CONNECTION"
    capacity_scaler              = 0
    failover                     = false
    group                        = google_compute_region_instance_group_manager.upstream.instance_group
    max_connections              = 0
    max_connections_per_endpoint = 0
    max_connections_per_instance = 0
    max_rate                     = 0
    max_rate_per_endpoint        = 0
    max_rate_per_instance        = 0
    max_utilization              = 0
  }
  timeouts {}
}