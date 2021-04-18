resource "google_service_account" "demo" {
  account_id   = "svc-${var.name}"
  display_name = "${var.name} Service Account"
}

data "google_compute_image" "demo" {
  family  = "cos-stable"
  project = "cos-cloud"
}

resource "google_compute_instance_template" "demo" {
  for_each = var.regions

  name_prefix  = "${var.name}-envoy-${each.key}"
  machine_type = "f1-micro"
  tags = [ "fw-allow-health-check" ]

  // boot disk
  disk {
    source_image = data.google_compute_image.demo.self_link
  } 

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.demo.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = google_compute_subnetwork.demo[each.key].self_link
  }

  metadata = {
    "user-data" = templatefile("${path.module}/files/cloud-init.yaml.tpl",
        {
          envoy_config = indent(4, file("${path.module}/files/envoy_demo.yaml"))
        }
      )
    }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "demo" {  
  for_each = var.regions
  name = "${var.name}-${each.key}-igm"

  base_instance_name         = "${each.key}-${var.name}-envoy"
  region                     = each.key

  version {
    instance_template = google_compute_instance_template.demo[each.key].self_link
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