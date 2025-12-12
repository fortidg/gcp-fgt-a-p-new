# VPC Networks
resource "google_compute_network" "vpc_networks" {
  for_each = local.vpc_networks

  name                    = each.value.name
  auto_create_subnetworks = false
}

# Subnets
resource "google_compute_subnetwork" "compute_subnetwork" {
  for_each = local.subnets

  name          = each.value.name
  ip_cidr_range = each.value.cidr_range
  region        = var.region
  network       = google_compute_network.vpc_networks[each.value.vpc_key].id
}