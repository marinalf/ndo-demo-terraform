[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/marinalf/ndo-demo-terraform)

## Sample [terraform](https://www.terraform.io) code with [Cloud Network Controller](https://www.cisco.com/c/en/us/solutions/data-center-virtualization/application-centric-infrastructure/cloud-network-controller.html) and [Orchestrator](https://www.cisco.com/c/en/us/products/cloud-systems-management/multi-site-orchestrator/index.html)

This project shows how Nexus Dashboard Orchestrator (NDO) provides consistent network and policy orchestration across AWS and Azure, how Cloud Network Controller normalizes and translates a cloud-like policy model into public cloud native constructs, and how Terraform can be leveraged to automate these operations through the former [mso](https://registry.terraform.io/providers/CiscoDevNet/mso/latest) provider.

**High Level Diagram**

<img width="800" src="images/hld.png">

**Use Case: Consistent Policy across Multicloud**

This code builds a VPC in AWS and a VNet in Azure with dedicated subnets to host a Web application (Web EPG in Cloud Network Controller translates to SG and ASG/NSG respectively). Internet access is also enabled using a contract/filter which translates into proper security rules. Web services can then be deployed either in AWS or Azure, or moved between clouds. 

**Pre-requisites**

1) Cloud Network Controller running in AWS and Azure managed by NDO. 
2) Cloud connectivity between AWS and Azure pre-provisioned and automated by NDO with IPSec and BGP EVPN.

**Software**

| Name      | Version |
| --------- | ------- |
| [Terraform Provider](https://registry.terraform.io/providers/CiscoDevNet/mso/latest)|  >= 0.7.1   |
[NDO](https://www.cisco.com/c/en/us/products/cloud-systems-management/multi-site-orchestrator/index.html) | 2.3.x/4.1.X

**Installation**

1. Install and set up your [terraform](https://www.terraform.io/downloads.html) environment
2. Clone/copy the .tf files (main.tf, variables.tf, data_sources.tf, deployer.tf and provider.tf) onto your terraform runtime environment
3. Create an override.tf file with your NDO, AWS, and Azure credentials
4. Set up your environment with the parallelism.env file
5. If using workspaces or remote backend, the provider.tf needs to be modified accordingly. 

**Usage**

```
terraform init
terraform plan
terraform apply
```

**Remarks**

This code demonstrates the use of standard terraform modules with a single schema definition and one template stretched across both clouds. The intent is show a simple scenario to build upon for multiple schema/templates which can be enhanced with more advanced modules on a per use case basis. 