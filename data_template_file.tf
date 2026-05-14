locals {
  rendered_templates = {
    for key, value in local.template_files : key => templatefile("${path.module}/templates/${value.template_file}", {
      fgt_name         = value.fgt_name
      admin_port       = var.admin_port
      fgt_password     = var.fgt_password
      healthcheck_port = var.healthcheck_port
      license_type     = value.license_type
      license_file     = value.license_file
      license_token    = value.license_token
      port1-ip         = value.port1-ip
      port2-ip         = value.port2-ip
      port2-sub        = value.port2-sub
      port2_alias_ips  = value.port2_alias_ips
      port3-ip         = value.port3-ip
      port3-sub        = value.port3-sub
      port4-ip         = value.port4-ip
      port4-sub        = value.port4-sub
      elb_ip           = value.elb_ip
      ilb_ip           = value.ilb_ip
      ext_gw           = value.ext_gw
      int_gw           = value.int_gw
      ha_gw            = value.ha_gw
      mgmt_gw          = value.mgmt_gw
      other_fgt_ha_ip  = value.other_fgt_ha_ip
      priority         = value.priority
      ha_netmask       = var.ha_netmask
    })
  }
}