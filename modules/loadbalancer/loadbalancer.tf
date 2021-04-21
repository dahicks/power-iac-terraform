# forwarding rule exposes LB to internet on port 80
resource "google_compute_global_forwarding_rule" "demo" {
  name       = "global-rule"
  target     = google_compute_target_http_proxy.demo.id
  port_range = "80"
}
# url map required for LB to route inbound request(s) to backend services
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
# target proxy pushes requests from URL map to backend service
resource "google_compute_target_http_proxy" "demo" {  
  name        = "target-proxy"
  description = "a description"
  url_map     = google_compute_url_map.demo.id
}
# Maps load balancer backend to compute instance group
resource "google_compute_backend_service" "demo" {
  name        = "backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_health_check.demo.id]
  
  dynamic "backend" {
    for_each = var.instance_groups  
    content {      
      group = backend.value
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