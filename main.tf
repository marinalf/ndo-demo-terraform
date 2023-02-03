# Define Tenant

resource "mso_tenant" "tenant" {
  name         = var.tenant.tenant_name
  display_name = var.tenant.display_name
  description  = var.tenant.description
  site_associations {
    site_id                 = data.mso_site.azure_site.id
    vendor                  = "azure"
    azure_access_type       = "shared"
    azure_subscription_id   = var.azure.azure_subscription_id
    azure_shared_account_id = var.azure.azure_subscription_id
  }
  site_associations {
    site_id                = data.mso_site.aws_site.id
    vendor                 = "aws"
    aws_account_id         = var.aws.aws_account_id
    is_aws_account_trusted = true
  }
}

# Define schema and template

resource "mso_schema" "schema1" {
  name = var.schema_name
  template {
    name         = var.template_name
    display_name = var.template_name
    tenant_id    = mso_tenant.tenant.id
  }
}

# Associate schema and template with cloud sites

resource "mso_schema_site" "azure_site" {
  schema_id     = mso_schema.schema1.id
  template_name = tolist(mso_schema.schema1.template)[0].name
  site_id       = data.mso_site.azure_site.id
  undeploy_on_destroy = true
}

resource "mso_schema_site" "aws_site" {
  schema_id     = mso_schema.schema1.id
  template_name = tolist(mso_schema.schema1.template)[0].name
  site_id       = data.mso_site.aws_site.id
  undeploy_on_destroy = true
}

### Template Level - Networking

# Create VRF to be stretched between AWS & Azure

resource "mso_schema_template_vrf" "vrf1" {
  schema_id    = mso_schema.schema1.id
  template     = tolist(mso_schema.schema1.template)[0].name
  name         = var.vrf_name
  display_name = var.vrf_name
}

### Site Level - Networking

# Define Region, CIDR and Subnets in Azure

resource "mso_schema_site_vrf_region" "azure_region" {
  schema_id          = mso_schema.schema1.id
  template_name      = mso_schema_site.azure_site.template_name
  vrf_name           = mso_schema_template_vrf.vrf1.name
  site_id            = mso_schema_site.azure_site.site_id
  region_name        = var.azure_region_name
  vpn_gateway        = false
  hub_network_enable = true # This enables VNet Peering to Infra/Hub VNet
  hub_network = {
    name        = "default"
    tenant_name = "infra"
  }
  cidr {
    cidr_ip = var.azure_cidr_ip
    primary = true

    dynamic "subnet" {
      for_each = var.azure_user_subnets
      content {
        ip   = subnet.value.ip
        name = subnet.value.name
      }
    }
  }
}

## Define Region, CIDR and Subnets in AWS

resource "mso_schema_site_vrf_region" "aws_region" {
  schema_id          = mso_schema.schema1.id
  template_name      = mso_schema_site.aws_site.template_name
  site_id            = data.mso_site.aws_site.id
  vrf_name           = mso_schema_template_vrf.vrf1.name
  region_name        = var.aws_region_name
  vpn_gateway        = false
  hub_network_enable = true # This enables attachment to Infra TGW
  hub_network = {
    name        = var.tgw_name
    tenant_name = "infra"
  }
  cidr {
    cidr_ip = var.aws_cidr_ip
    primary = true

    dynamic "subnet" {
      for_each = var.aws_tgw_subnets
      content {
        ip    = subnet.value.ip
        name  = subnet.value.name
        zone  = subnet.value.zone
        usage = "gateway"
      }
    }
    dynamic "subnet" {
      for_each = var.aws_user_subnets
      content {
        ip    = subnet.value.ip
        name  = subnet.value.name
        zone  = subnet.value.zone
        usage = "user"
      }
    }
  }
}

### Template Level - Policies

# Create Application Profile

resource "mso_schema_template_anp" "ap" {
  schema_id    = mso_schema.schema1.id
  template     = tolist(mso_schema.schema1.template)[0].name
  name         = var.ap_name
  display_name = var.ap_name
}


# Create Web EPG

resource "mso_schema_template_anp_epg" "cloud_epg" {
  schema_id     = mso_schema.schema1.id
  template_name = tolist(mso_schema.schema1.template)[0].name
  anp_name      = mso_schema_template_anp.ap.name
  name          = var.epg_name
  display_name  = var.epg_name
  vrf_name      = mso_schema_template_vrf.vrf1.name
}

# Create External EPG to represent Internet

resource "mso_schema_template_external_epg" "externalepg" {
  schema_id         = mso_schema.schema1.id
  template_name     = tolist(mso_schema.schema1.template)[0].name
  external_epg_name = var.ext_epg
  external_epg_type = "cloud"
  display_name      = var.ext_epg
  vrf_name          = mso_schema_template_vrf.vrf1.name
  anp_name          = mso_schema_template_anp.ap.name
  selector_name     = var.ext_epg_selector
  selector_ip       = var.ext_epg_selector_ip
}

## Create Filter and Contract to allow Internet access to Web EPG

# Create Filter

resource "mso_schema_template_filter_entry" "filter_entry_ext_epg" {
  schema_id          = mso_schema.schema1.id
  template_name      = tolist(mso_schema.schema1.template)[0].name
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

# Create Contract

resource "mso_schema_template_contract" "contract_ext_epg" {
  schema_id     = mso_schema.schema1.id
  template_name = tolist(mso_schema.schema1.template)[0].name
  contract_name = var.contract_name
  display_name  = var.contract_name
  scope         = "context"
  directives    = ["none"]
  filter_relationship {
    filter_name = mso_schema_template_filter_entry.filter_entry_ext_epg.name
  }
}

# Add Contract as Provider to Web EPG

resource "mso_schema_template_anp_epg_contract" "epg_provider" {
  schema_id         = mso_schema.schema1.id
  template_name     = tolist(mso_schema.schema1.template)[0].name
  anp_name          = mso_schema_template_anp.ap.name
  epg_name          = mso_schema_template_anp_epg.cloud_epg.name
  contract_name     = mso_schema_template_contract.contract_ext_epg.contract_name
  relationship_type = "provider"
}

# Add Contract as Consumer to External EPG (Internet)

resource "mso_schema_template_external_epg_contract" "ext_epg_consumer" {
  schema_id         = mso_schema.schema1.id
  template_name     = tolist(mso_schema.schema1.template)[0].name
  external_epg_name = mso_schema_template_external_epg.externalepg.external_epg_name
  contract_name     = mso_schema_template_contract.contract_ext_epg.contract_name
  relationship_type = "consumer"
}

### Site Level - Policies

## Create Endpoint Selector for the Web EPG

resource "mso_schema_site_anp_epg_selector" "epgSel1" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.azure_site.id
  template_name = mso_schema_site.azure_site.template_name
  anp_name      = mso_schema_template_anp.ap.name
  epg_name      = mso_schema_template_anp_epg.cloud_epg.name
  name          = "epgSel1"
  expressions {
    key      = var.epg_selector_key
    operator = "equals"
    value    = var.epg_selector_value
  }
}

resource "mso_schema_site_anp_epg_selector" "epgSel2" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.aws_site.id
  template_name = mso_schema_site.aws_site.template_name
  anp_name      = mso_schema_template_anp.ap.name
  epg_name      = mso_schema_template_anp_epg.cloud_epg.name
  name          = "epgSel2"
  expressions {
    key      = var.epg_selector_key
    operator = "equals"
    value    = var.epg_selector_value
  }
}
