# Netbox requests
data "http" "prefix_requests" {
  for_each = {
    for label in toset(local.prefix_labels) : label => label
  }

  url = "https://netbox.xor.mx/api/ipam/prefixes/?tag=${each.value}"
  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.netbox_api_token}"
  }
}

# Project VPC
data "google_compute_network" "main_vpc" {
  name = var.vpc_name
}
# Custom subnetworks in Common
data "google_compute_subnetwork" "main_vpc_subnetworks" {
  for_each = {
    for subnet_link in data.google_compute_network.main_vpc.subnetworks_self_links : substr(regex("\\/[\\da-z-]+$", subnet_link), 1, -1) => {
      self_link = subnet_link
    }
  }
  self_link = each.value.self_link
}
# Default VPC
data "google_compute_network" "default_VPC" {
  name = "default"
}
# Subnetworks in VPC default
data "google_compute_subnetwork" "default_vpc_subnetworks" {
  for_each = toset(data.google_compute_network.default_VPC.subnetworks_self_links == null ? [] : data.google_compute_network.default_VPC.subnetworks_self_links)
  self_link = each.value

  depends_on = [
    data.google_compute_network.default_VPC
  ]
}

locals {
  netbox_api_token = "8405c3521c42b508656ec0c00dd3a9fbe746d034"
  prefix_labels = ["dc-hz", "dc-eq", "dc-lw", "dc-wz", "dc-sc-ams3-gl", "dc-sc-ams3-eu", "users-vpn-ssl", "users-office", "gke-common-gitlab-runners-pods", "gke-common-gitlab-runners-services","azure-prod"]

  custom_subnetworks_ranges_added = [
    for subnet in var.custom_subnets : data.google_compute_subnetwork.main_vpc_subnetworks[subnet].ip_cidr_range
  ]
  default_VPC_subnetworks_ranges_added = [
    for subnet in data.google_compute_subnetwork.default_vpc_subnetworks : subnet.ip_cidr_range
  ]

  dc_unified = flatten([
    [
      for label, res in data.http.prefix_requests : [
        for k, el in lookup(jsondecode(res.response_body), "results", {}) : el.prefix
      ]
    ],
    var.custom_source_ranges,
    local.custom_subnetworks_ranges_added,
    var.include_subnets_from_VPC_default ? compact(local.default_VPC_subnetworks_ranges_added) : []
  ])
}

# Add randomness
resource "random_string" "random_postfix" {
  length    = 16
  lower     = true
  upper     = false
  special   = false
}

# RESOURCE
resource "google_compute_firewall" "dc_ranges_firewall" {
  name          = "dc-ranges-firewall-${random_string.random_postfix.result}-for-${var.vpc_name}"
  network       = var.vpc_self_link
  direction     = var.direction

  source_ranges = local.dc_unified
  target_tags   = var.target_tags

  allow {
    protocol    = var.allow.protocol
    ports       = var.allow.ports
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
