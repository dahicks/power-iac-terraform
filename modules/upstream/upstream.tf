data "google_compute_image" "echo" {
  family  = "cos-stable"
  project = "cos-cloud"
}

resource "google_compute_region_instance_group_manager" "echo" {    
  name = "${var.name}-${var.region}-igm"

  base_instance_name         = "${var.region}-${var.name}"
  region                     = var.region

  version {
    instance_template = google_compute_instance_template.echo.self_link
  }

  target_size  = 1

  named_port {
    name = "http"
    port = 3000
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.echo.id
    initial_delay_sec = 300
  }

  update_policy {
    type = "PROACTIVE"
    max_surge_fixed = 0
    max_unavailable_fixed = 3
    minimal_action = "REPLACE"
    replacement_method = "SUBSTITUTE"
  }

  depends_on = [
    google_compute_instance_template.echo
  ]
}

resource "google_compute_instance_template" "echo" {
  name_prefix  = "${var.name}-${var.region}"
  machine_type = "f1-micro"
  tags = [ "fw-allow-health-check","internal" ]

  // boot disk
  disk {
    source_image = data.google_compute_image.echo.self_link
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
    "user-data" = templatefile("${path.module}/files/cloud-init.yaml.tpl",{})
  }

  lifecycle {
    create_before_destroy = true
  }
}