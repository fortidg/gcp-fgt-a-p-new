# GCP Active/Passive dual zone FortiGate POC

This terraform will deploy a High Availability pair of FortiGate VMs with 3 interfaces.  Port1 will be in the "untrust" network, port 2 will be in the "trust" network port 3 will serve as heartbeat and port 4 will be management.  There are no Public IP's assigned to port1.  This design uses a "Load Balancer Sandwich", with FortiGates in a back end set.  The external load balancer has been assigned a public IP address.  Port3 on both FortiGates have been assigned public IP addresses.  You will be able to manage the FortiGates with these.

## How do you run these?

1. Log into GCP console and open a cloud shell.
1. use `git clone https://github.com/fortidg/gcp-fgt-a-p-existing.git` to clone this repo.
1. Open `terraform.tfvars.example`Change the name to 'terraform.tfvars' update the required variables (project, region, zone, zone2, prefix, untrust_subnet1_name, trust_subnet1_name, ha_subnet1_name, mgmt_subnet1_name, fortigate_vm_image, fortigate_machine_type)
1. Run `terraform get`.
1. Run `terraform init`.
1. Run `terraform plan`.
1. If the plan looks good, run `terraform apply`.

The prefix mentioned above is simply a memorable string of text to differentiate the resources deployed by this code.

### Licensing

There are three options for licensing the FortiGate VMs:

"flex" (default) - Set license_type to "flex" and add two unused FortiFlex tokens to the "flex_tokens" variable.  Ensure you are using the BYOL FortiGate image.  For Example:

```sh
flex_tokens = ["C5095E394QAZ3E640112", "DC65640C2QAZDD9CBC76"]
```

"byol" - Set license_type to "byol" and copy two valid fortigate licenses into the local directory.  Ensure you are using the BYOL FortiGate image. Update terraform.tfvars with the names of the licenses.  For example:

```sh
fortigate_license_files = {
  fgt1_instance    = { name = license1.lic }
  fgt2_instance = { name = license2.lic }
}
```

"payg" - Set license_type to "payg" and ensure that you are using the PAYG FortiGate Image  

If you wish to deploy FortGates in only one zone, you can use the same value for "zone" and "zone2".

FortiGates can be managed by putting `https://<fortigate-public-ip>:8443` into the url bar of your favorite browser. These IP addresses will be part of the Terraform outputs upon using apply.


This terraform will use existing customer subnets/networks.  It is assumed that Cloud NAT router and cloud nat are already configured in the "untrust" and "ha/management" subnets.

This terraform assumes that customer networks already have firewall rules in place.  You will need to update them based on the below link:

https://docs.fortinet.com/document/fortigate/6.4.0/ports-and-protocols/303168/fortigate-open-ports

In addition to those ports, you will need to allow tcp 8008 in both the trust and untrust subnets to allow heartbeat probes for load balancers.

Conversely, if you wish to allow all you can un-comment the compute_firewall stanzas in resources.tf.