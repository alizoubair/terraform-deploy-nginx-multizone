resource "google_compute_network" "custom_network" {
    provider                = google
    name                    = "custom-network"
    auto_create_subnetworks = true
    project                 = var.project_id
}

resource "google_compute_firewall" "http_rule" {
    name    = "${var.region}-http-8080"
    network = google_compute_network.custom_network.name
    allow {
        protocol = "tcp"
        ports = [
            "8080",
        ]
    }
    source_ranges = var.firewall_source_ranges
    target_tags = [
        var.vm_tag
    ]
}

resource "google_compute_firewall" "ssh_rule" {
    name    = "${var.region}-ssh"
    network = google_compute_network.custom_network.name
    allow {
        protocol = "tcp"
        ports = [
            "22",
        ]
    }
    source_ranges = ["35.235.240.0/20"]
    target_tags = [
        var.vm_tag
    ]
}

resource "google_compute_firewall" "internal_rule" {
    name    = "network-gce-allow-internal"
    network = google_compute_network.custom_network.name
    allow {
        protocol = "tcp"
        ports = [
            "0-65535",
        ]
    }
    source_ranges = ["10.128.0.0/9"]
    target_tags = [
        var.vm_tag
    ]
}

resource "google_compute_router" "router" {
    name    = "network-gce-router"
    region  = var.region
    network = google_compute_network.custom_network.name
}

resource "google_compute_router_nat" "router-nat" {
    name                               = "network-gce-router-nat"
    router                             = google_compute_router.router.name
    region                             = google_compute_router.router.region
    nat_ip_allocate_option             = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}