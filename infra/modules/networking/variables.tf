variable "project_id" {
    description = "ID of the GCP project."
    type        = string
}

variable "region" {
    description = "The region chosen to be used."
    type        = string
}

variable "firewall_source_ranges" {
    description = "The firewall will apply only to traffic that has source IP address in these ranges. These ranges must be expressed in CIDR format."
    type        = list(string)
    default     = []
}

variable "vm_tag" {
    description = "Tag for targeting firewall rule"
    type        = string
}