variable "project" {}
variable "region" {}
variable "zone" {}
variable "zone2" {}

variable "prefix" {}

# FortiGates
variable "fortigate_machine_type" {
  type        = string
  description = "Machine type for FortiGate instances. Supported families: n2-standard, c4-standard, c4a-standard"
  validation {
    condition     = can(regex("^(n2-standard|c4-standard|c4a-standard)-", var.fortigate_machine_type))
    error_message = "Machine type must be from n2-standard, c4-standard, or c4a-standard families."
  }
}
variable "fortigate_license_type" {
  type        = string
  default     = null
  description = "Image license type: payg or byol. Defaults to payg when license_type is payg, otherwise byol."
  validation {
    condition     = var.fortigate_license_type == null || contains(["payg", "byol"], var.fortigate_license_type)
    error_message = "fortigate_license_type must be payg or byol."
  }
}

variable "fortigate_version" {
  type        = string
  default     = "latest"
  description = "FortiOS image family version (for example 76 or 80), or latest for the newest published image."
  validation {
    condition     = var.fortigate_version == "latest" || can(regex("^[0-9]{2,3}$", var.fortigate_version))
    error_message = "fortigate_version must be latest or a two- or three-digit image family version such as 76 or 80."
  }
}

variable "fortigate_vm_image" {
  type        = string
  default     = null
  description = "Optional full image path. Overrides fortigate_version and fortigate_license_type."
  validation {
    condition     = var.fortigate_vm_image == null || length(trimspace(var.fortigate_vm_image)) > 0
    error_message = "fortigate_vm_image must be a nonempty image path when set."
  }
}

variable "fortigate_license_files" {}

variable "enable_fips_ciphers" {
  type        = bool
  default     = false
  description = "Enable FortiGate FIPS cipher mode in the startup configuration."
}

variable "enable_loopback" {
  type        = bool
  default     = false
  description = "Use lo0 for the external load balancer probe address instead of a secondary IP on port1."
}

variable "fgt_username" {
  type        = string
  default     = ""
  description = "FortiGate Username"
}
variable "fgt_password" {
  type        = string
  default     = ""
  description = "FortiGate Password"
}
variable "ha_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "FGCP HA group password"
}
variable "admin_port" {}

# debug
variable "enable_output" {
  type        = bool
  default     = true
  description = "Debug"
}

variable "healthcheck_port" {
  type        = number
  default     = 8008
  description = "Port used for LB health checks"
}

# VPC Network Configuration
variable "vpc_networks" {
  type = map(object({
    name = string
  }))
  description = "VPC networks configuration"
  default = {
    untrust_vpc = { name = "untrust-vpc" }
    trust_vpc   = { name = "trust-vpc" }
    ha_vpc      = { name = "ha-vpc" }
    mgmt_vpc    = { name = "mgmt-vpc" }
  }
}

# Subnet Configuration
variable "subnets" {
  type = map(object({
    name       = string
    cidr_range = string
    vpc_key    = string
  }))
  description = "Subnets configuration"
  default = {
    untrust-subnet-1 = {
      name       = "untrust-subnet-1"
      cidr_range = "10.0.1.0/24"
      vpc_key    = "untrust_vpc"
    }
    trust-subnet-1 = {
      name       = "trust-subnet-1"
      cidr_range = "10.0.2.0/24"
      vpc_key    = "trust_vpc"
    }
    ha-subnet-1 = {
      name       = "ha-subnet-1"
      cidr_range = "10.0.3.0/24"
      vpc_key    = "ha_vpc"
    }
    mgmt-subnet-1 = {
      name       = "mgmt-subnet-1"
      cidr_range = "10.0.4.0/24"
      vpc_key    = "mgmt_vpc"
    }
  }
}
variable "ha_netmask" {
  type        = string
  description = "netmask of the ha subnet"
  default     = "255.255.255.0"
}

variable "flex_tokens" {
  type        = list(string)
  default     = ["", ""]
  description = "List of FortiFlex tokens to be applied during bootstrapping"
}

variable "license_type" {
  type        = string
  default     = "flex"
  description = "License type: flex, payg or byol"
}

# Alias IP configuration for trust VPC
variable "trust_alias_ip_ranges" {
  type = map(list(object({
    ip_cidr_range         = string
    subnetwork_range_name = optional(string)
  })))
  description = "Optional alias IP ranges for trust VPC network interfaces. Keys should be 'fgt1' and 'fgt2'"
  default     = {}
}
