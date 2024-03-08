output "private_network" {
    description = "VPC network"
    value       = google_compute_network.custom_network
}