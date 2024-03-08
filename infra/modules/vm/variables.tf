variable "project_id" {
    description = "ID of the GCP project."
    type        = string
}

variable "private_network_id" {
    description = "VPC id"
    type        = string
}

variable "vm_tag" {
    description = "Tag for targeting firewall rule"
    type        = string
}

variable "region" {
    description = "The region chosen to be used."
    type        = string
}

variable "zones" {
    description = "A list of zones that mig can be placed in. The list depends on the region chosen."
    type        = list(string)
}

variable "machine_type" {
    description = "Machine type"
    type        = string
    default     = "e2-micro"
}

variable "service_account" {
    description = "List of service accounts to be enabled."
    type = object({
        email  = string
        scopes = set(string)
    })
}

variable "lb_port_name" {
    description = "Lb backend port name"
    type        = string
}

variable "labels" {
    description = "A map of key/value label pairs to assign to the resources."
    type        = map(string)
}