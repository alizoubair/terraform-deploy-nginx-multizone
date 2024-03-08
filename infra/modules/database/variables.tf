variable "project_id" {
    description = "The project ID to manage the Cloud SQL resources."
    type        = string
}

variable "region" {
    description = "The region chosen to be used."
    type        = string
}

variable "db_settings" {
    description = "The map of the various DB settings"
    type        = map(any)
}

variable "private_network_id" {
    description = "VPC id"
    type        = string
}

variable "availability_type" {
    description = "The availaility type of the Cloud SQL instance, high availability (REGIONAL) or single zone (ZONAL)."
    type        = string
    validation {
      condition     = contains(["REGIONAL", "ZONAL"], var.availability_type)
      error_message = "Alloxed values for type are \"REGIONAL\", \"ZONAL\"."
    }
}

variable "service_account" {
    description = "Service account which should have read permission to access the database password."
    type        = string
}