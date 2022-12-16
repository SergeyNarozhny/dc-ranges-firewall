variable "vpc_name" {
    description = "VPC name"
    type        = string
    default     = "common"
}

variable "vpc_self_link" {
    description = "VPC self_link"
    type        = string
}

variable "direction" {
    type        = string
    default     = "INGRESS"
}

variable "allow" {
    type = object({
        protocol = string
        ports = list(string)
    })
    default = {
        protocol = "tcp"
        ports    = ["0-65535"]
    }
}

variable "custom_source_ranges" {
    type        = list(string)
    default     = []
}

variable "custom_subnets" {
    type        = list(string)
    default     = []
}

variable "target_tags" {
    type        = list(string)
    default     = []
}
