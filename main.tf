data "http" "hz_prefixes" {
  url = "https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-hz"
  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.netbox_api_token}"
  }
}
data "http" "eq_prefixes" {
  url = "https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-eq"
  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.netbox_api_token}"
  }
}
data "http" "lw_prefixes" {
  url = "https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-lw"
  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.netbox_api_token}"
  }
}
data "http" "wz_prefixes" {
  url = "https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-wz"
  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.netbox_api_token}"
  }
}
data "http" "sc_am3_gl_prefixes" {
  url = "https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-sc-ams3-gl"
  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.netbox_api_token}"
  }
}
data "http" "sc_am3_eu_prefixes" {
  url = "https://netbox.xor.mx/api/ipam/prefixes/?tag=dc-sc-ams3-eu"
  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.netbox_api_token}"
  }
}

# Add randomness
resource "random_string" "random_postfix" {
  length    = 16
  lower     = true
  upper     = false
  special   = false
}

locals {
  netbox_api_token = "8405c3521c42b508656ec0c00dd3a9fbe746d034"

  hz_prefixes = [
    for k, el in lookup(jsondecode(data.http.hz_prefixes.response_body), "results", {}) : el.prefix
  ]
  eq_prefixes = [
    for k, el in lookup(jsondecode(data.http.eq_prefixes.response_body), "results", {}) : el.prefix
  ]
  lw_prefixes = [
    for k, el in lookup(jsondecode(data.http.lw_prefixes.response_body), "results", {}) : el.prefix
  ]
  wz_prefixes = [
    for k, el in lookup(jsondecode(data.http.wz_prefixes.response_body), "results", {}) : el.prefix
  ]
  sc_am3_gl_prefixes = [
    for k, el in lookup(jsondecode(data.http.sc_am3_gl_prefixes.response_body), "results", {}) : el.prefix
  ]
  sc_am3_eu_prefixes = [
    for k, el in lookup(jsondecode(data.http.sc_am3_eu_prefixes.response_body), "results", {}) : el.prefix
  ]
  dc_unified = concat(local.hz_prefixes, local.eq_prefixes, local.lw_prefixes, local.wz_prefixes, local.sc_am3_gl_prefixes, local.sc_am3_eu_prefixes, var.custom_source_range)
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
