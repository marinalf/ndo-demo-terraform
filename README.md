[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/marinalf/ndo-demo-terraform)

## Sample [Terraform](https://www.terraform.io) integration with [Cloud ACI](https://www.cisco.com/c/en/us/solutions/data-center-virtualization/application-centric-infrastructure/cloud-aci.html) and [Orchestrator](https://www.cisco.com/c/en/us/products/cloud-systems-management/multi-site-orchestrator/index.html)

This project shows how Nexus Dashboard Orchestrator (NDO) provides consistent network and policy orchestration across AWS and Azure, how Cloud ACI normalizes and translates the ACI policy model into public cloud native constructs, and how Terraform can be leveraged to automate these operations through the [mso](https://registry.terraform.io/providers/CiscoDevNet/mso/latest) provider.

**High Level Diagram**

<img width="800" src="https://github.com/marinalf/ndo-demo-terraform/blob/main/images/hld.png">

## Use Case: Stretched Policy with ACI Multicloud

This code builds a VPC in AWS and a VNet in Azure with dedicated subnets to host a Web application (Web EPG in Cloud ACI translates to SG and ASG/NSG respectively). Internet access is also enabled using a contract/filter which translates into proper security rules. Web services can then be deployed either in AWS or Azure, or moved between clouds.

**Pre-requisites**

Cloud ACI running in AWS and Azure managed by NDO. The underlying cloud connectivity between AWS and Azure automated by NDO and both cloud sites connected via IPSec and BGP EVPN.

**Terraform Provider**

| Name      | Version |
| --------- | ------- |
| [mso](https://registry.terraform.io/providers/CiscoDevNet/mso/latest)|  >= 0.5.0   |

**Installation**

1. Install and set up your [terraform](https://www.terraform.io/downloads.html) environment
2. Clone/copy the .tf files (main.tf, variables.tf, terraform.tfvars, and provider.tf) onto your terraform runtime environment
3. Create an override.tf file with your NDO, AWS, and Azure credentials
4. Set up your environment with the parallelism.env file

**Usage**

```
terraform init
terraform plan
terraform apply
```
