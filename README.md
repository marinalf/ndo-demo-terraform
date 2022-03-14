# Sample [terraform](https://www.terraform.io) integration with [Cisco Cloud ACI](https://www.cisco.com/c/en/us/solutions/data-center-virtualization/application-centric-infrastructure/cloud-aci.html) running in AWS and Azure and managed by Nexus Dashboard Orchestrator.

This project shows how Nexus Dashboard Orchestrator provides centralized management and consistent policies automation to both AWS and Azure by running Cloud ACI, and how Terraform can be leveraged to automate operations using the mso provider.

**High Level Diagram**

<img width="600" alt="aws" src="https://github.com/marinalf/ndo-demo-terraform/blob/main/images/hld.png">

## Use Case: Stretched Policy with ACI Multicloud

This code builds a VPC in AWS and a VNet in Azure with dedicated subnets to host a Web application (the Web EPG in Cloud ACI translates to SG and NSG respectively), and enable Web access from Internet using contracts. Web services can be deployed either in AWS or Azure.

**Pre-requisites**

Cloud ACI running in AWS and Azure managed by Nexus Dashboard Orchestrator (NDO). The underlying cloud connectivity between AWS and Azure has been automated by NDO and both sites are connected via IPSec and BGP EVPN.

**Providers**

| Name      | Version |
| --------- | ------- |
| [mso](https://registry.terraform.io/providers/CiscoDevNet/mso/latest)|  >= 0.5.0   |

**Installation**

1. Install and set up your [terraform](https://www.terraform.io/downloads.html) environment
2. Clone/copy the .tf files (main.tf, variables.tf, terraform.tfvars, and provider.tf) onto your terraform runtime environment
3. Create a override.tf file with your NDO, AWS, and Azure credentials
4. Set up your environment with the parallelism.env file

**Usage**

```
terraform init
terraform plan
terraform apply
```
