#  Values of variables to override default values defined in variables.tf

# Site names as seen on Nexus Dashboard
aws_site_name = "aws"
azure_site_name = "azure"

# Schema & Template
schema_name   = "multicloud"
template_name = "policy-stretch"

# Stretched VRF in AWS and Azure

vrf_name = "vrf1"

# User VPC in AWS

aws_region_name   = "eu-west-2"
aws_cidr_ip = "10.1.0.0/16"

tgw-a_subnet = "10.1.1.0/24"
zone1   = "eu-west-2a"

tgw-b_subnet = "10.1.2.0/24"
zone2   = "eu-west-2b"

aws_subnet_web = "10.1.3.0/24"
zone3   = "eu-west-2a"

tgw_name = "TGW" # this is the TGW name configured during initial cAPIC setup

# User VNet in Azure

azure_region_name   = "eastus"
azure_cidr_ip = "20.1.0.0/16"
azure_subnet_web = "20.1.3.0/24"

# Define Security Policies

ap_name      = "MyApp"
epg_name     = "Web"
epg_selector_key = "Custom:epg"
epg_selector_value = "web"

ext_epg = "Internet"
ext_epg_selector = "Internet"
ext_epg_selector_ip = "0.0.0.0/0"

filter_name = "all-traffic"
contract_name = "internet-access"
