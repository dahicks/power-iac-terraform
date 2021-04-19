output "network_details" {
  value = {
    network = google_compute_network.demo.self_link
    subnets = { for k,v in var.regions :  k => google_compute_subnetwork.demo[k].self_link }
  }
}