##  Existing sites in Nexus Dashboard Orchestrator

data "mso_site" "azure_site" {
  name = var.azure_site_name
}

data "mso_site" "aws_site" {
  name = var.aws_site_name
}