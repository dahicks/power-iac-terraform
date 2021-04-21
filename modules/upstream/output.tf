output "echo_ip_address" {
  value = google_compute_forwarding_rule.upstream.ip_address
}