output "echo_ip_address" {
  value = google_compute_forwarding_rule.echo-internal-tcp.ip_address
}