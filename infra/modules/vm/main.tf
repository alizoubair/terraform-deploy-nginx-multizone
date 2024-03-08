module "instance_template" {
    source  = "terraform-google-modules/vm/google///modules/instance_template"
    version = "10.1.1"

    name_prefix  = "${var.zones[0]}-temp"
    machine_type = var.machine_type
    source_image = "https://www.googleapis.com/compute/beta/projects/debian-cloud/global/images/debian-11-bullseye-v20240110"
    tags = [
        var.vm_tag,
    ]
    network = var.private_network_id
    service_account = {
        email  = var.service_account.email
        scopes = var.service_account.scopes
    }

    # install nginx and serve a simple web page
    metadata = {
        startup-script = <<-EOF1
            #! /bin/bash
            set -euo pipefail

            export DEBIAN_FRONTEND=noninteractive
            sudo apt-get update
            sudo apt-get install -y nginx-light jq

            NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
            IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
            METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

            sudo cat <<EOF > /var/www/html/index.html
            <pre
            NAME: $NAME
            IP: $IP
            Metadata: $METADATA
            </pre
            EOF
        EOF1
    }
    labels  = var.labels
}

module "mig" {
    source  = "terraform-google-modules/vm/google//modules/mig"
    version = "10.1.1"

    project_id                = var.project_id
    mig_name                  = "${var.region}-group-autoscale"
    hostname                  = "${var.region}-group-autoscale"
    instance_template         = module.instance_template.self_link
    region                    = var.region
    distribution_policy_zones = var.zones
    autoscaling_enabled       = true
    max_replicas              = 2
    min_replicas              = 1
    cooldown_period           = 120
    autoscaler_name           = "autoscaler"
    autoscaling_cpu = [
        {
            target            = 0.5,
            predictive_method = null
        },
    ]
    health_check_name = "health-check-http-8080"
    health_check = {
        type                = "http"
        port                = 8080
        proxy_header        = "NONE"
        request             = ""
        response            = ""
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        host                = ""
        initial_delay_sec   = 600
        request_path        = "/bin/view/Main"
        enable_logging      = true
    }
    named_ports = [
        {
            name = var.lb_port_name
            port = 8080
        },
    ]
}