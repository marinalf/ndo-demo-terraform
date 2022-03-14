##  Existing sites in Nexus Dashboard Orchestrator

data "mso_site" "aws_site" {
  name = var.aws_site_name
}

data "mso_site" "azure_site" {
  name = var.azure_site_name
}

## Define Tenant

resource "mso_tenant" "tenant" {
  name         = var.tenant.tenant_name
  display_name = var.tenant.display_name
  description  = var.tenant.description
  site_associations {
    site_id                = data.mso_site.aws_site.id
    vendor                 = "aws"
    aws_account_id         = var.aws.aws_account_id
    is_aws_account_trusted = true
  }
  site_associations {
    site_id                = data.mso_site.azure_site.id
    vendor                 = "azure"
    azure_subscription_id  = var.azure.azure_subscription_id
    azure_access_type      = "shared"
    azure_shared_account_id = var.azure.azure_subscription_id
  }
}

## Define schema and template

resource "mso_schema" "schema1" {
  name          = var.schema_name
  template_name = var.template_name
  tenant_id     = mso_tenant.tenant.id
}

## Associate schema and template with cloud sites

resource "mso_schema_site" "aws_site" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.aws_site.id
  template_name = mso_schema.schema1.template_name
}

resource "mso_schema_site" "azure_site" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.azure_site.id
  template_name = mso_schema.schema1.template_name
}

## Create VRF to be stretched to AWS and Azure

resource "mso_schema_template_vrf" "vrf1" {
  schema_id        = mso_schema.schema1.id
  template         = mso_schema.schema1.template_name
  name             = var.vrf_name
  display_name     = var.vrf_name
}

resource "mso_schema_site_vrf" "aws_site" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.aws_site.template_name
  site_id       = data.mso_site.aws_site.id
  vrf_name      = mso_schema_template_vrf.vrf1.name
}

resource "mso_schema_site_vrf" "azure_site" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.azure_site.template_name
  site_id       = data.mso_site.azure_site.id
  vrf_name      = mso_schema_template_vrf.vrf1.name
}

## Define Region, CIDR and Subnets in AWS

resource "mso_schema_site_vrf_region" "aws_region" {
  schema_id          = mso_schema.schema1.id
  template_name      = mso_schema_site.aws_site.template_name
  site_id            = data.mso_site.aws_site.id
  vrf_name           = mso_schema_site_vrf.aws_site.vrf_name
  region_name        = var.aws_region_name
  vpn_gateway        = false
  hub_network_enable = true #This enables TGW attachment to Infra TGW
  hub_network = {
    name        = var.tgw_name
    tenant_name = "infra"
  }
  cidr {
    cidr_ip = var.aws_cidr_ip
    primary = true

    subnet {
      ip    = var.tgw-a_subnet
      zone  = var.zone1
      usage = "gateway"
    }

    subnet {
      ip    = var.tgw-b_subnet
      zone  = var.zone2
      usage = "gateway"
    }

    subnet {
      ip   = var.aws_subnet_web
      zone = var.zone3
      usage = "user"
    }

  }
}

## Define Region, CIDR and Subnets in Azure

resource "mso_schema_site_vrf_region" "azure_region" {
  schema_id          = mso_schema.schema1.id
  template_name      = mso_schema_site.azure_site.template_name
  site_id            = data.mso_site.azure_site.id
  vrf_name           = mso_schema_site_vrf.azure_site.vrf_name
  region_name        = var.azure_region_name
  vpn_gateway        = false
  hub_network_enable = true #This enables VNet Peering to Infra/Hub VNet
  cidr {
    cidr_ip = var.azure_cidr_ip
    primary = true

    subnet {
      ip    = var.azure_subnet_web
    }
  }
}

### EPG Web to be stretched in AWS and Azure

## Create Application Profile

resource "mso_schema_template_anp" "ap" {
  schema_id    = mso_schema.schema1.id
  template     = mso_schema.schema1.template_name
  name         = var.ap_name
  display_name = var.ap_name
}

resource "mso_schema_site_anp" "aws" {
  schema_id     = mso_schema.schema1.id
  anp_name      = mso_schema_template_anp.ap.name
  template_name = mso_schema_site.aws_site.template_name
  site_id       = data.mso_site.aws_site.id
}

resource "mso_schema_site_anp" "azure" {
  schema_id     = mso_schema.schema1.id
  anp_name      = mso_schema_template_anp.ap.name
  template_name = mso_schema_site.azure_site.template_name
  site_id       = data.mso_site.azure_site.id
}

## Create Web EPG

resource "mso_schema_template_anp_epg" "cloud_epg" {
  schema_id                  = mso_schema.schema1.id
  template_name              = mso_schema.schema1.template_name
  anp_name                   = mso_schema_template_anp.ap.name
  name                       = var.epg_name
  display_name               = var.epg_name
  bd_name                    = var.bd_name
  vrf_name                   = mso_schema_template_vrf.vrf1.name
}

resource "mso_schema_site_anp_epg" "aws_epg" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.aws_site.template_name
  site_id       = data.mso_site.aws_site.id
  anp_name      = mso_schema_site_anp.aws.anp_name
  epg_name      = mso_schema_template_anp_epg.cloud_epg.name
}

resource "mso_schema_site_anp_epg" "azure_epg" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.azure_site.template_name
  site_id       = data.mso_site.azure_site.id
  anp_name      = mso_schema_site_anp.azure.anp_name
  epg_name      = mso_schema_template_anp_epg.cloud_epg.name
}

## Create Endpoint Selector for the Web EPG

resource "mso_schema_site_anp_epg_selector" "epgSel1" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.aws_site.id
  template_name = mso_schema_site.aws_site.template_name
  anp_name      = mso_schema_template_anp_epg.cloud_epg.anp_name
  epg_name      = mso_schema_site_anp_epg.aws_epg.epg_name
  name          = "epgSel1"
  expressions {
    key      = var.epg_selector_key
    operator = "equals"
    value    = var.epg_selector_value
  }
}

resource "mso_schema_site_anp_epg_selector" "epgSel2" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.azure_site.id
  template_name = mso_schema_site.azure_site.template_name
  anp_name      = mso_schema_template_anp_epg.cloud_epg.anp_name
  epg_name      = mso_schema_site_anp_epg.azure_epg.epg_name
  name          = "epgSel2"
  expressions {
    key      = var.epg_selector_key
    operator = "equals"
    value    = var.epg_selector_value
  }
}

## Create External EPG to represent Internet

resource "mso_schema_template_external_epg" "externalepg" {
  schema_id         = mso_schema.schema1.id
  template_name     = mso_schema.schema1.template_name
  external_epg_name = var.ext_epg
  external_epg_type = "cloud"
  display_name      = var.ext_epg
  vrf_name          = mso_schema_template_vrf.vrf1.name
  anp_name          = mso_schema_template_anp.ap.name
  selector_name     = var.ext_epg_selector
  selector_ip       = var.ext_epg_selector_ip
}

resource "mso_schema_site_external_epg" "aws_externalepg" {
  schema_id         = mso_schema_template_external_epg.externalepg.schema_id
  template_name     = mso_schema_template_external_epg.externalepg.template_name
  site_id           = mso_schema_site.aws_site.site_id
  external_epg_name = mso_schema_template_external_epg.externalepg.external_epg_name
}

resource "mso_schema_site_external_epg" "azure_externalepg" {
  schema_id         = mso_schema_template_external_epg.externalepg.schema_id
  template_name     = mso_schema_template_external_epg.externalepg.template_name
  site_id           = mso_schema_site.azure_site.site_id
  external_epg_name = mso_schema_template_external_epg.externalepg.external_epg_name
}

# Create Filter and Contract to allow Internet access to Web EPG

## Create Filter

resource "mso_schema_template_filter_entry" "filter_entry_ext_epg" {
  schema_id         = mso_schema.schema1.id
  template_name     = mso_schema.schema1.template_name
  name               = var.filter_name
  display_name       = var.filter_name
  entry_name         = "Any"
  entry_display_name = "Any"
  destination_from   = "unspecified"
  destination_to     = "unspecified"
  source_from        = "unspecified"
  source_to          = "unspecified"
  arp_flag           = "unspecified"
}

## Create Contract

resource "mso_schema_template_contract" "contract_ext_epg" {
  schema_id         = mso_schema.schema1.id
  template_name     = mso_schema.schema1.template_name
  contract_name = var.contract_name
  display_name  = var.contract_name
  scope         = "context"
  directives    = ["none"]
}

### Associate filter with Contract

resource "mso_schema_template_contract_filter" "contract_filter_ass" {
  schema_id         = mso_schema.schema1.id
  template_name     = mso_schema.schema1.template_name
  contract_name = mso_schema_template_contract.contract_ext_epg.contract_name
  filter_type   = "bothWay"
  filter_name   = mso_schema_template_filter_entry.filter_entry_ext_epg.name
  directives    = ["none", "log"]
}

#### Add Contract as Provider to Web EPG

resource "mso_schema_template_anp_epg_contract" "epg_provider" {
  schema_id         = mso_schema.schema1.id
  template_name     = mso_schema.schema1.template_name
  anp_name          = mso_schema_template_anp.ap.name
  epg_name          = mso_schema_template_anp_epg.cloud_epg.name
  contract_name     = mso_schema_template_contract.contract_ext_epg.contract_name
  relationship_type = "provider"
}

#### Add Contract as Consumer to extEPGs

resource "mso_schema_template_external_epg_contract" "ext_epg_consumer" {
  schema_id         = mso_schema.schema1.id
  template_name     = mso_schema.schema1.template_name
  external_epg_name = mso_schema_template_external_epg.externalepg.external_epg_name
  contract_name     = mso_schema_template_contract.contract_ext_epg.contract_name
  relationship_type = "consumer"
}

### Deploy Template

resource "mso_schema_template_deploy" "template_deployer" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema.schema1.template_name
  depends_on = [
    mso_tenant.tenant,
    mso_schema.schema1,
    mso_schema_site.aws_site,
    mso_schema_site.azure_site,
    mso_schema_template_vrf.vrf1,
    mso_schema_site_vrf.aws_site,
    mso_schema_site_vrf.azure_site,
    mso_schema_site_vrf_region.aws_region,
    mso_schema_site_vrf_region.azure_region,
    mso_schema_template_anp.ap,
    mso_schema_site_anp.aws,
    mso_schema_site_anp.azure,
    mso_schema_template_anp_epg.cloud_epg,
    mso_schema_site_anp_epg.aws_epg,
    mso_schema_site_anp_epg.azure_epg,
    mso_schema_site_anp_epg_selector.epgSel1,
    mso_schema_site_anp_epg_selector.epgSel2,
    mso_schema_template_external_epg.externalepg,
    mso_schema_site_external_epg.aws_externalepg,
    mso_schema_site_external_epg.azure_externalepg,
    mso_schema_template_filter_entry.filter_entry_ext_epg,
    mso_schema_template_contract.contract_ext_epg,
    mso_schema_template_contract_filter.contract_filter_ass,
    mso_schema_template_anp_epg_contract.epg_provider,
    mso_schema_template_external_epg_contract.ext_epg_consumer
  ]
  #undeploy = true
}
