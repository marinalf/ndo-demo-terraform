# Define the provider source

terraform {
  required_providers {
    mso = {
      source  = "CiscoDevNet/mso"
      version = ">= 0.5.0"
    }
  }
}

# MSO Provider Config

provider "mso" {
  username = var.ndo.username
  password = var.ndo.password
  url      = var.ndo.url
  domain   = var.ndo.domain
  insecure = true
  platform = "nd"
}
