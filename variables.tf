variable "project" {}
variable "region" {}
variable "zone" {}
variable "zone2" {}

variable "prefix" {}

# FortiGates
variable "fortigate_machine_type" {}
variable "fortigate_vm_image" {}

variable "fortigate_license_files" {}

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