locals {
    vm_tag       = "${var.region}-autoscale"
    lb_port_name = "backend-port"
    vm_sa_email  = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    zones_base = {
        default = data.google_compute_zones.available.names
        user    = compact(var.zones)
    }
    zones = local.zones_base[length(compact(var.zones)) == 0 ? "default" : "user"]
}

data "google_project" "project" {
    project_id = var.project_id
}

data "google_compute_zones" "available" {
    depends_on = [ 
        module.project_services
    ]
    project = var.project_id
    region  = var.region
}

module "project_services" {
    source  = "terraform-google-modules/project-factory/google//modules/project_services"
    version = "~> 14.0"

    disable_services_on_destroy = false
    project_id                  = var.project_id
    
    activate_apis = [
        "compute.googleapis.com",
        "file.googleapis.com",
        "iam.googleapis.com",
        "servicenetworking.googleapis.com",
        "sqladmin.googleapis.com",
        "secretmanager.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "config.googleapis.com"
    ]
}

module "networking" {
    source = "./modules/networking"

    project_id             = var.project_id
    region                 = var.region
    firewall_source_ranges = concat(
        [module.load_balancer.lb_global_ip],
        var.firewall_source_ranges
    )
    vm_tag                 = local.vm_tag
    depends_on = [ 
        module.project_services 
    ]
}

module "database" {
    source = "./modules/database"

    project_id         = var.project_id
    region             = var.region
    private_network_id = module.networking.private_network.id
    availability_type  = var.availability_type
    service_account    = local.vm_sa_email
    db_settings        = var.db_settings
    depends_on = [ 
        module.project_services
     ]
}

module "vm" {
    source = "./modules/vm"

    region             = var.region
    zones              = var.zones
    private_network_id = module.networking.private_network.id
    project_id         = var.project_id
    labels             = var.labels
    vm_tag             = local.vm_tag
    service_account = {
        email = local.vm_sa_email
        scopes = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring.write",
            "https://www.googleapis.com/auth/service.management.readonly",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/trace.append",
            "https://www.googleapis.com/auth/devstorage.full_control",
            "https://www.googleapis.com/auth/compute",
        ]
    }
    lb_port_name = local.lb_port_name
    depends_on = [ 
        module.project_services
    ]
}

module "load_balancer" {
    source = "./modules/load-balancer"

    project_id   = var.project_id
    mig          = module.vm.mig
    lb_port_name = local.lb_port_name

    depends_on = [ 
        module.project_services 
    ]
}