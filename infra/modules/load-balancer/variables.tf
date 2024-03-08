variable "project_id" {
    description = "ID of the GCP project."
    type        = string
}

variable "lb_port_name" {
    description = "LB backend port name"
    type        = string
}

variable "mig" {
    description = "Managed instance group"
    type        = any
}