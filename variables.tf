# All credentials and sensitive information are declared in the override.tf file.

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

# Site names as seen on Nexus Dashboard

variable "aws_site_name" {
  type    = string
  default = "cnc-aws"
}

variable "azure_site_name" {
  type    = string
  default = "cnc-azure"
}

## Template Level

# Tenant

variable "tenant" {
  type = map(any)
  default = {
    tenant_name  = "multicloud"
    display_name = "multicloud"
    description  = "This is a demo tenant created by Terraform"
  }
}

# Schema & Template

variable "schema_name" {
  type    = string
  default = "multicloud-devnet"
}

variable "template_name" {
  type    = string
  default = "distributed-app"
}

# Stretched VRF in AWS and Azure

variable "vrf_name" {
  type    = string
  default = "vrf1"
}

## Site Level - Networking

# User VPC in AWS

variable "aws_region_name" {
  type    = string
  default = "eu-west-2"
}

variable "tgw_name" {
  type    = string
  default = "TGW" # This is the TGW name configured during initial CNC setup
}

variable "aws_cidr_ip" {
  type    = string
  default = "10.1.0.0/16"
}

variable "aws_tgw_subnets" {
  type = map(object({
    name = string
    ip   = string
    zone = string
  }))
  default = {
    tgw-a-subnet = {
      name  = "tgw-a-subnet"
      ip    = "10.1.1.0/24"
      zone  = "eu-west-2a"
      usage = "gateway"
    },
    tgw-b-subnet = {
      name  = "tgw-b-subnet"
      ip    = "10.1.2.0/24"
      zone  = "eu-west-2b"
      usage = "gateway"
    }
  }
}

variable "aws_user_subnets" {
  type = map(object({
    name = string
    ip   = string
    zone = string
  }))
  default = {
    web-subnet = {
      name  = "web-subnet"
      ip    = "10.1.3.0/24"
      zone  = "eu-west-2a"
      usage = "user"
    },
    db-subnet = {
      name  = "db-subnet"
      ip    = "10.1.4.0/24"
      zone  = "eu-west-2b"
      usage = "user"
    }
  }
}

# User VNet in Azure

variable "azure_region_name" {
  type    = string
  default = "uksouth"
}

variable "azure_cidr_ip" {
  type    = string
  default = "20.1.0.0/16"
}

variable "azure_user_subnets" {
  type = map(object({
    name = string
    ip   = string
  }))
  default = {
    web-subnet = {
      name = "web-subnet"
      ip   = "20.1.3.0/24"
    },
    db-subnet = {
      name = "db-subnet"
      ip   = "20.1.4.0/24"
    }
  }
}

## Template Level - Policies

variable "ap_name" {
  type    = string
  default = "MyApp"
}

variable "epg_name" {
  type    = string
  default = "Web"
}

variable "epg_selector_key" {
  type    = string
  default = "Custom:epg"
}

variable "epg_selector_value" {
  type    = string
  default = "web"
}

variable "ext_epg" {
  type    = string
  default = "Internet"
}

variable "ext_epg_selector" {
  type    = string
  default = "Internet"
}

variable "ext_epg_selector_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "filter_name" {
  type    = string
  default = "all-traffic"
}

variable "contract_name" {
  type    = string
  default = "internet-access"
}



