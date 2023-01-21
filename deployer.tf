# Deploy Template
/*
resource "mso_schema_template_deploy" "template_deployer" {
  schema_id     = mso_schema.schema1.id
  template_name = var.template_name
  depends_on = [
    mso_tenant.tenant,
    mso_schema.schema1,
    mso_schema_site.azure_site,
    mso_schema_template_anp.ap,
    mso_schema_template_vrf.vrf1,
    mso_schema_template_anp_epg.cloud_epg,
    mso_schema_site_vrf_region.aws_region,
    mso_schema_site_vrf_region.azure_region,
    mso_schema_site_anp_epg_selector.epgSel1,
    mso_schema_site_anp_epg_selector.epgSel2,
    mso_schema_template_external_epg.externalepg,
    mso_schema_template_contract.contract_ext_epg,
    mso_schema_template_anp_epg_contract.epg_provider,
    mso_schema_template_filter_entry.filter_entry_ext_epg,
    mso_schema_template_external_epg_contract.ext_epg_consumer
  ]
}
*/