resource "random_string" "string" {
  length           = 3
  special          = true
  override_special = ""
  min_lower        = 3
}

resource "google_compute_address" "compute_address" {
  for_each = local.compute_addresses

  name         = each.value.name
  region       = each.value.region
  address_type = each.value.address_type
  subnetwork   = each.value.subnetwork
  address      = each.value.address
}


resource "google_compute_disk" "compute_disk" {
  for_each = local.compute_disks

  name = each.value.name
  size = each.value.size
  type = each.value.type
  zone = each.value.zone
}

resource "google_compute_instance" "compute_instance" {
  for_each = local.compute_instances

  name         = each.value.name
  zone         = each.value.zone
  machine_type = each.value.machine_type

  can_ip_forward = each.value.can_ip_forward
  tags           = each.value.tags

  boot_disk {
    initialize_params {
      image = each.value.boot_disk_initialize_params_image
    }
  }

  dynamic "attached_disk" {
    for_each = each.value.attached_disk
    content {
      source = attached_disk.value.source
    }
  }

  dynamic "network_interface" {
    for_each = each.value.network_interface
    content {
      network    = network_interface.value.network
      subnetwork = network_interface.value.subnetwork
      network_ip = network_interface.value.network_ip
      dynamic "access_config" {
        for_each = network_interface.value.access_config
        content {
          nat_ip = access_config.value.nat_ip
        }
      }
    }
  }

  metadata = each.value.metadata

  service_account {
    scopes = each.value.service_account_scopes
  }

  allow_stopping_for_update = each.value.allow_stopping_for_update
}


resource "google_compute_instance_group" "fgt-umigs" {
  for_each = local.umigs

  name      = each.value.name
  zone      = each.value.zone
  instances = each.value.instances
}

resource "google_compute_region_health_check" "health_check" {
  name               = "${var.prefix}-healthcheck-http${var.healthcheck_port}-${var.region}"
  region             = var.region
  timeout_sec        = 2
  check_interval_sec = 2

  http_health_check {
    port = var.healthcheck_port
  }
}


resource "google_compute_region_backend_service" "ibes" {
  for_each = local.ibess

  name     = each.value.name
  region   = each.value.region
  network  = each.value.network
  protocol = "UNSPECIFIED"

  backend {
    group          = each.value.group1
    balancing_mode = "CONNECTION"
  }
  backend {
    group          = each.value.group2
    balancing_mode = "CONNECTION"
  }

  health_checks = [google_compute_region_health_check.health_check.self_link]

}

resource "google_compute_region_backend_service" "ebes" {
  for_each = local.ebess

  name                  = each.value.name
  region                = each.value.region
  load_balancing_scheme = each.value.load_balancing_scheme
  protocol              = "UNSPECIFIED"

  backend {
    group          = each.value.group1
    balancing_mode = "CONNECTION"
  }
  backend {
    group          = each.value.group2
    balancing_mode = "CONNECTION"
  }

  health_checks = [google_compute_region_health_check.health_check.self_link]

}

resource "google_compute_forwarding_rule" "ifwd_rule" {
  for_each              = local.ifwd_rules
  name                  = each.value.name
  region                = each.value.region
  network               = each.value.network
  subnetwork            = each.value.subnetwork
  ip_address            = each.value.ip_address
  all_ports             = true
  load_balancing_scheme = each.value.load_balancing_scheme
  ip_protocol           = "L3_DEFAULT"
  backend_service       = each.value.backend_service
  allow_global_access   = true
}

resource "google_compute_forwarding_rule" "efwd_rule" {
  for_each              = local.efwd_rules
  name                  = each.value.name
  region                = each.value.region
  network               = each.value.network
  subnetwork            = each.value.subnetwork
  ip_address            = each.value.ip_address
  all_ports             = true
  load_balancing_scheme = each.value.load_balancing_scheme
  ip_protocol           = "L3_DEFAULT"
  backend_service       = each.value.backend_service

}


#enable all traffic to ilb
resource "google_compute_route" "default_route" {
  name         = "${var.prefix}-rt-default-via-fgt-${random_string.string.result}"
  dest_range   = "0.0.0.0/0"
  network      = google_compute_network.vpc_networks["trust_vpc"].id
  next_hop_ilb = google_compute_address.compute_address["ilb-ip"].address
  priority     = 100
}

resource "google_compute_firewall" "compute_firewall" {
  for_each = local.compute_firewalls

  name               = each.value.name
  network            = each.value.network
  direction          = each.value.direction
  source_ranges      = each.value.source_ranges
  destination_ranges = each.value.destination_ranges

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
    }
  }
}