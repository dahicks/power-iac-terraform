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


resource "google_compute_global_forwarding_rule" "demo" {
  name       = "global-rule"
  target     = google_compute_target_http_proxy.demo.id
  port_range = "80"
}

resource "google_compute_target_http_proxy" "demo" {  
  name        = "target-proxy"
  description = "a description"
  url_map     = google_compute_url_map.demo.id
}

resource "google_compute_url_map" "demo" {  
  name            = "url-map-target-proxy"
  description     = "a description"
  default_service = google_compute_backend_service.demo.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.demo.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.demo.id
    }
  }
}

# Maps load balancer backend to compute instance group
resource "google_compute_backend_service" "demo" {
  name        = "backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_health_check.demo.id]

  dynamic "backend" {
    for_each = var.regions    
    content {      
      group = google_compute_region_instance_group_manager.demo[backend.key].instance_group                      
    }
  }  
}

# Compute instance Load Balancer Health check
resource "google_compute_health_check" "demo" {
  name               = "check-backend"
  timeout_sec        = 1
  check_interval_sec = 15

  http_health_check {
    port = 10000
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.demo.ip_address
}