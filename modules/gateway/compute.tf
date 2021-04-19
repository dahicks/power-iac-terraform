data "google_compute_image" "demo" {
  family  = "cos-stable"
  project = "cos-cloud"
}

resource "google_compute_instance_template" "demo" {
  name_prefix  = "${var.name}-envoy-${var.region}"
  machine_type = "f1-micro"
  tags = [ "fw-allow-health-check" ]

  // boot disk
  disk {
    source_image = data.google_compute_image.demo.self_link
  } 

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  metadata = {
    "user-data" = templatefile("${path.module}/files/envoy/cloud-init.yaml.tpl",
        {
          envoy_config = indent(4, file("${path.module}/files/envoy/envoy_demo.yaml"))
        }
      )
    }

  lifecycle {
    create_before_destroy = true
  }
}

# Compute instance Load Balancer Health check
resource "google_compute_health_check" "demo" {
  name               = "ig-healthcheck-${var.region}"
  timeout_sec        = 1
  check_interval_sec = 15

  http_health_check {
    port = 10000
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "demo" {  
  name = "${var.name}-${var.region}-igm"

  base_instance_name         = "${var.region}-${var.name}-envoy"
  region                     = var.region

  version {
    instance_template = google_compute_instance_template.demo.self_link
  }

  target_size  = 1

  named_port {
    name = "http"
    port = 10000
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.demo.id
    initial_delay_sec = 300
  }

  depends_on = [
    google_compute_instance_template.demo
  ]
}