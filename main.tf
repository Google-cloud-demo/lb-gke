# ---------------------------------------------------------------------------------------------------------------------
# LAUNCH A LOAD BALANCER WITH INSTANCE GROUP AND STORAGE BUCKET BACKEND
#
# This is an example of how to use the http-load-balancer module to deploy a HTTP load balancer
# with multiple backends and optionally ssl and custom domain.
# ---------------------------------------------------------------------------------------------------------------------

#terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  #required_version = ">= 0.12.26"

 # required_providers {
  #  google = {
   #   source  = "hashicorp/google"
    #  version = "~> 3.43.0"
   # }
   # google-beta = {
    #  source  = "hashicorp/google-beta"
      #version = "~> 3.43.0"
  #  }
 # }
#}

# ------------------------------------------------------------------------------
# CONFIGURE OUR GCP CONNECTION
# ------------------------------------------------------------------------------

#provider "google" {
#  region  = var.region
#  project = var.project
#}

provider "google-beta" {
  region  = var.region
  project = var.project
}

# ------------------------------------------------------------------------------
# CREATE THE LOAD BALANCER
# ------------------------------------------------------------------------------

module "lb" {
  source                = "./modules/http-load-balancer"
  name                  = var.name
  project               = var.project
  url_map               = google_compute_url_map.default.self_link
  dns_managed_zone_name = var.dns_managed_zone_name
  custom_domain_names   = [var.custom_domain_name]
  create_dns_entries    = var.create_dns_entry
  dns_record_ttl        = var.dns_record_ttl
  enable_http           = var.enable_http
  enable_ssl            = var.enable_ssl
  ssl_certificates      = google_compute_managed_ssl_certificate.default.*.self_link

  custom_labels = var.custom_labels
}

# ------------------------------------------------------------------------------
# CREATE THE URL MAP TO MAP PATHS TO BACKENDS

# ------------------------------------------------------------------------------


resource "google_compute_global_forwarding_rule" "default-ssl" {
  name       = "dev-controlplane"
  target     = google_compute_target_https_proxy.default-ssl.self_link
  port_range = "443"
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_target_https_proxy" "default-ssl" {
  provider         = google-beta
  name             = "target-proxy-ssl"
  description      = "a description"
 # ssl_certificates = ["mysslcert"]
  ssl_certificates = google_compute_managed_ssl_certificate.default.*.self_link
  url_map          = google_compute_url_map.default.self_link
}

#---------------------------------------------------------------------------------
resource "google_compute_managed_ssl_certificate" "default" {
  name = "nginx-ingress"

  managed {
    domains = ["dev-controlplane.cloud.korewireless.com"]
  }
}

resource "google_compute_url_map" "default" {
  name        = "dev-controlplane"
  description = "a description"

  default_service = google_compute_backend_service.default.id

#  host_rule {
#    hosts        = ["sslcert.tf-test.club"]
#    path_matcher = "allpaths"
#  }

#  path_matcher {
#    name            = "allpaths"
#    default_service = google_compute_backend_service.default.id

 #   path_rule {
 #     paths   = ["/*"]
 #     service = google_compute_backend_service.default.id
  #  }
 # }
}

# ------------------------------------------------------------------------------
# CREATE THE BACKEND SERVICE CONFIGURATION FOR THE INSTANCE GROUP
# ------------------------------------------------------------------------------

resource "google_compute_backend_service" "default" {
  name        = "dev-controlplane"
  port_name   = "http"
  protocol    = "HTTP"
  
#  backend {
#    group = "gke-cluster-1-default-pool-84c4a035-grp"
# }



  timeout_sec = 10

  health_checks = [google_compute_http_health_check.default.id]
}
# ------------------------------------------------------------------------------
# CONFIGURE HEALTH CHECK FOR THE API BACKEND
# ------------------------------------------------------------------------------

resource "google_compute_http_health_check" "default" {
  name               = "nginx-ingress"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
