variable "project_id" {
    description = "ID of the GCP project."
    type        = string
}

variable "region" {
    description = "Compute region to deploy to."
    type        = string
    default     = "us-central1"
}

variable "zones" {
    description = "Compute zones to deploy to."
    type        = list(string)
    default     = [ "us-central1-a", "us-central1-b" ]
}

variable "deployment_name" {
    description = "The name of this particular deployment, will get added as a prefix to most resources."
    type        = string
    default     = "terraform-nginx-app" 
}

variable "availability_type" {
    description = "The availability type of the Cloud SQL instance, high availability (REGIONAL) or single zone (ZONAL)."
    type        = string
    default     = "REGIONAL"
    validation {
        condition     = contains(["REGIONAL", "ZONAL"], var.availability_type)
        error_message = "Allowed values for type are \"REGIONAL\", \"ZONAL\"."
    }
}

variable "firewall_source_ranges" {
    description = "The firewall will apply only to traffic that has IP address in these ranges. These ranges must be expressed in CIDR format."
    type        = list(string)
    default     = [
        // Health check service ip
        "130.211.0.0/22",
        "35.191.0.0/16",
    ] 
}

variable "db_settings" {
    description = "The map of the various DB settings"
    type        = map(any)
    default = {
        user_name        = "user"
        db_name          = "sample-database"
        database_tier    = "db-f1-micro"
        database_version = "MYSQL_8_0"
    }
}

variable "labels" {
    description = "A map of key/value label pairs to assign to the resources."
    type        = map(string)
    default = {
        app = "terraform-deploy-nginx-gce"
    }
}