# look up latest stable version of COS image
data "google_compute_image" "cos" {
  family  = "cos-stable"
  project = "cos-cloud"
}

# Compute instance Load Balancer Health check
resource "google_compute_health_check" "envoy" {
  name               = "ig-healthcheck-envoy-${var.name}-${var.region}"
  timeout_sec        = 1
  check_interval_sec = 15

  http_health_check {
    port = 10000
  }

  lifecycle {
    create_before_destroy = true
  }
}

# instance group manager manages the scaling characteristics
# of a set of compute instances
resource "google_compute_region_instance_group_manager" "envoy" {  
  name = "${var.name}-${var.region}-envoy-igm"

  base_instance_name         = "${var.region}-${var.name}-envoy"
  region                     = var.region

  version {
    instance_template = google_compute_instance_template.envoy.self_link
  }

  target_size  = 1

  named_port {
    name = "http"
    port = 10000
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.envoy.id
    initial_delay_sec = 300
  }

  depends_on = [
    google_compute_instance_template.envoy
  ]
}

# instance template defines configuration of a compute instance
resource "google_compute_instance_template" "envoy" {
  name_prefix  = "${var.name}-envoy-${var.region}"
  machine_type = "f1-micro"
  tags = [ "fw-allow-health-check","internal" ]

  // boot disk
  disk {
    source_image = data.google_compute_image.cos.self_link
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
          envoy_config = indent(4, templatefile("${path.module}/files/envoy/envoy_demo.yaml.tpl", {
            address = var.upstream.address
            port = var.upstream.port
          }))
        }
      )
    }

  lifecycle {
    create_before_destroy = true
  }
}