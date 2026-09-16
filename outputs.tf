# FGT-IP
output "fgt1_ip" {
  value = format("https://%s:8443", google_compute_address.compute_address["fgt1-static-ip"].address)
}

output "fgt2_ip" {
  value = format("https://%s:8443", google_compute_address.compute_address["fgt2-static-ip"].address)
}

output "elb_ip" {
  value = google_compute_address.compute_address["elb-static-ip"].address
}

output "ilb_ip" {
  value = google_compute_address.compute_address["ilb-ip"].address
}

# FGT-Username
output "fgt_username" {
  value = var.fgt_username
}

# FGT-Password
output "fgt_password" {
  value = var.fgt_password
}


