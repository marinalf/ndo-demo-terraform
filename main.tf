##  Define data sources

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

## Define schema

resource "mso_schema" "schema1" {
  name          = var.schema_name
  template_name = var.template_name
  tenant_id     = mso_tenant.tenant.id
}

## Associate Schema / template with Sites

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

## Create VRF

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

## Associate with Region and Zones in Site Local Templates

resource "mso_schema_site_vrf_region" "aws_region" {
  schema_id          = mso_schema.schema1.id
  template_name      = mso_schema_site.aws_site.template_name
  site_id            = data.mso_site.aws_site.id
  vrf_name           = mso_schema_site_vrf.aws_site.vrf_name
  region_name        = var.region_name
  vpn_gateway        = false
  hub_network_enable = true
  hub_network = {
    name        = var.tgw_name
    tenant_name = "infra"
  }
  cidr {
    cidr_ip = var.cidr_ip
    primary = true

    subnet {
      ip    = var.cloud_subnet_tgw-a
      zone  = var.zone1
      usage = "gateway"
    }

    subnet {
      ip    = var.cloud_subnet_tgw-b
      zone  = var.zone2
      usage = "gateway"
    }

    subnet {
      ip   = var.cloud_subnet_user1
      zone = var.zone3
      usage = "user"
    }

  }
}

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

/*
resource "mso_schema_site_anp" "azure" {
  schema_id     = mso_schema.schema1.id
  anp_name      = mso_schema_template_anp.ap.name
  template_name = mso_schema_site.azure_site.template_name
  site_id       = data.mso_site.azure_site.id
}

*/
## Create EPG

resource "mso_schema_site_anp_epg" "aws_epg" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.aws_site.template_name
  site_id       = data.mso_site.aws_site.id
  anp_name      = mso_schema_site_anp.aws.anp_name
  epg_name      = mso_schema_template_anp_epg.cloud_epg.name
}

resource "mso_schema_template_anp_epg" "cloud_epg" {
  schema_id                  = mso_schema.schema1.id
  template_name              = mso_schema.schema1.template_name
  anp_name                   = mso_schema_template_anp.ap.name
  name                       = var.epg_name
  vrf_name                   = mso_schema_template_vrf.vrf1.name
}


## Create Endpoint Selector

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
    mso_schema_template_anp.ap,
    mso_schema_site_anp.aws,
    /* mso_schema_site_anp.azure,*/
    mso_schema_site_anp_epg.aws_epg,
    mso_schema_template_anp_epg.cloud_epg,
    mso_schema_site_anp_epg_selector.epgSel1
  ]
  #undeploy = true
}
