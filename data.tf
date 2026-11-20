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

data "google_compute_image" "fortigate" {
  count = var.fortigate_vm_image == null ? 1 : 0

  project     = "fortigcp-project-001"
  family      = var.fortigate_version == "latest" ? null : "fortigate-${var.fortigate_version}-${local.fortigate_image_license_type}"
  filter      = var.fortigate_version == "latest" ? "name eq ^${local.fortigate_image_name_prefix}-[0-9]+-[0-9]+-[0-9]+-w-license$" : null
  most_recent = var.fortigate_version == "latest"
}
