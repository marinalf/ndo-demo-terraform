
### All credentials and sensitive information are declared in the override.tf file.

# NDO Credentials

variable "ndo" {
  type = map(any)
  default = {
    username = "username"
    password = "password"
    url      = "url"
    domain   = "local"
  }
}

# AWS credentials

variable "aws" {
  type = object({
    aws_account_id = string
  })
  default = {
    aws_account_id = "account"
  }
}

# Azure credentials

variable "azure" {
  type = object({
    azure_subscription_id = string
  })
  default = {
    azure_subscription_id = "subscription"
  }
}

# Logical Configuration

variable "tenant" {
  type = map(any)
  default = {
    tenant_name  = "multicloud"
    display_name = "multicloud"
    description  = "This is a demo tenant created by Terraform"
  }
}
variable "aws_site_name" {
  type    = string
  default = "aws"
}

variable "azure_site_name" {
  type    = string
  default = "azure"
}

variable "schema_name" {
  type    = string
  default = "some_value"
}

variable "template_name" {
  type    = string
  default = "some_value"
}

variable "vrf_name" {
  type    = string
  default = "some_value"
}

variable "aws_region_name" {
  type    = string
  default = "some_value"
}

variable "tgw_name" {
  type    = string
  default = "your_tgw_name"
}

variable "aws_cidr_ip" {
  type    = string
  default = "some_value"
}

variable "tgw-a_subnet" {
  type    = string
  default = "some_value"
}

variable "tgw-b_subnet" {
  type    = string
  default = "some_value"
}

variable "aws_subnet_web" {
  type    = string
  default = "some_value"
}

variable "zone1" {
  type    = string
  default = "some_value"
}

variable "zone2" {
  type    = string
  default = "some_value"
}

variable "zone3" {
  type    = string
  default = "some_value"
}

variable "azure_region_name" {
  type    = string
  default = "some_value"
}

variable "azure_cidr_ip" {
  type    = string
  default = "some_value"
}

variable "azure_subnet_web" {
  type    = string
  default = "some_value"
}

variable "ap_name" {
  type    = string
  default = "some_value"
}

variable "epg_name" {
  type    = string
  default = "some_value"
}

variable "bd_name" {
  type    = string
  default = "some_value"
}

variable "epg_selector_value" {
  type    = string
  default = "some_value"
}

variable "epg_selector_key" {
  type    = string
  default = "Custom:some_value"
}

variable "ext_epg" {
  type    = string
  default = "some_value"
}

variable "ext_epg_selector" {
  type    = string
  default = "some_value"
}

variable "ext_epg_selector_ip" {
  type    = string
  default = "some_value"
}

variable "filter_name" {
  type    = string
  default = "some_value"
}

variable "contract_name" {
  type    = string
  default = "some_value"
}
