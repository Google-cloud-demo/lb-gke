# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A HTTP LOAD BALANCER
# This module deploys a HTTP(S) Cloud Load Balancer
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
}

# ------------------------------------------------------------------------------
# CREATE A PUBLIC IP ADDRESS
# ------------------------------------------------------------------------------

resource "google_compute_global_address" "default" {
  provider   = google-beta
  project      = var.project
  name         = "${var.name}-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}
# ------------------------------------------------------------------------------
# IF PLAIN HTTP ENABLED, CREATE FORWARDING RULE AND PROXY
# ------------------------------------------------------------------------------
#resource "google_compute_target_http_proxy" "http" {
#  count   = var.enable_http ? 1 : 0
#  project = var.project
#  name    = "${var.name}-http-proxy"
#  url_map = var.url_map
#}

#resource "google_compute_global_forwarding_rule" "http" {
#  provider   = google-beta
#  count      = var.enable_http ? 1 : 0
#  project    = var.project
#  name       = "${var.name}-http-rule"
#  target     = google_compute_target_http_proxy.http[0].self_link
#  ip_address = google_compute_global_address.default.address
#  port_range = "80"

#  depends_on = [google_compute_global_address.default]

#  labels = var.custom_labels
#}

# ------------------------------------------------------------------------------
# IF SSL ENABLED, CREATE FORWARDING RULE AND PROXY
# ------------------------------------------------------------------------------

#resource "google_compute_global_forwarding_rule" "https" {
#  provider   = google-beta
#  project    = var.project
#  count      = var.enable_ssl ? 1 : 0
#  name       = "${var.name}-https-rule"
#  target     = google_compute_target_https_proxy.default[0].self_link
#  ip_address = google_compute_global_address.default.address
#  port_range = "443"
#  depends_on = [google_compute_global_address.default]

#  labels = var.custom_labels
#}

#resource "google_compute_target_https_proxy" "default" {
#  project = var.project
#  count   = var.enable_ssl ? 1 : 0
#  name    = "${var.name}-https-proxy"
#  url_map = var.url_map

 # ssl_certificates = var.ssl_certificates
#}
