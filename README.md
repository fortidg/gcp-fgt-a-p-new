# GCP Active/Passive dual zone FortiGate POC

This terraform will deploy a High Availability pair of FortiGate VMs with 4 interfaces in newly created VPC networks. Port1 will be in the "untrust" network, port 2 will be in the "trust" network, port 3 will serve as heartbeat, and port 4 will be management. Each interface is deployed in a separate VPC network for security segmentation. There are no Public IP's assigned to port1. This design uses a "Load Balancer Sandwich", with FortiGates in a back end set. The external load balancer has been assigned a public IP address. Port4 (management) on both FortiGates have been assigned public IP addresses. You will be able to manage the FortiGates with these.

## How do you run these?

1. Log into GCP console and open a cloud shell.
1. Use `git clone https://github.com/fortidg/gcp-fgt-a-p-new.git` to clone this repo.
1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the required variables:
   - `project` - Your GCP project ID
   - `region` - GCP region (e.g., "us-central1")
   - `zone` - Primary availability zone (e.g., "us-central1-a")
   - `zone2` - Secondary availability zone (e.g., "us-central1-b")
   - `prefix` - A unique prefix for your resources
   - `fortigate_vm_image` - FortiGate VM image
   - `fortigate_machine_type` - VM instance type
1. Optionally customize VPC networks and subnets by uncommenting and modifying the `vpc_networks` and `subnets` variables in `terraform.tfvars`
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


## Network Architecture

This terraform will create new VPC networks and subnets with the following default configuration:

### VPC Networks Created:
- **untrust-vpc** (10.0.1.0/24) - External facing network for FortiGate port1
- **trust-vpc** (10.0.2.0/24) - Internal network for FortiGate port2
- **ha-vpc** (10.0.3.0/24) - HA synchronization network for FortiGate port3
- **mgmt-vpc** (10.0.4.0/24) - Management network for FortiGate port4

### Firewall Rules
The deployment includes firewall rules that allow all traffic on all networks. For production deployments, you should customize these rules based on your security requirements. Reference the FortiGate documentation for required ports:

https://docs.fortinet.com/document/fortigate/6.4.0/ports-and-protocols/303168/fortigate-open-ports

**Important**: TCP port 8008 is required on both trust and untrust networks for load balancer health checks.

### Customization
You can customize the VPC networks and subnet CIDR ranges by modifying the `vpc_networks` and `subnets` variables in your `terraform.tfvars` file. See `terraform.tfvars.example` for configuration examples.

### Cloud NAT
If your FortiGates need internet access for updates or licensing, you'll need to configure Cloud NAT gateways for the appropriate VPC networks after deployment.