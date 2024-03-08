resource "google_compute_backend_service" "lb" {
    project               = var.project_id
    load_balancing_scheme = "EXTERNAL_MANAGED"
    name                  = "lb-http-backend-vm-auto"
    port_name             = var.lb_port_name
    backend {
        group           = var.mig.instance_group
        max_utilization = 0.8
    }
    locality_lb_policy = "RING_HASH"
    session_affinity = "CLIENT_IP"
    consistent_hash {
        minimum_ring_size = 1024
    }
    health_checks = [
        var.mig.health_check_self_links[0],
    ]
}

resource "google_compute_global_address" "glb-address" {
    name = "lb-http-ip"
}

resource "google_compute_global_forwarding_rule" "lb_http_frontend" {
    project               = var.project_id
    load_balancing_scheme = "EXTERNAL_MANAGED"
    name                  = "lb-http-frontend"
    ip_address            = google_compute_global_address.glb-address.address
    port_range            = "80"
    target                = google_compute_target_http_proxy.lb_http.self_link
}

resource "google_compute_target_http_proxy" "lb_http" {
    project = var.project_id
    name    = "lb-http-8080-target-proxy"
    url_map = google_compute_url_map.lb_http.self_link
}

resource "google_compute_url_map" "lb_http" {
    project         = var.project_id
    default_service = google_compute_backend_service.lb.self_link
    name            = "lb-http-8080"
}