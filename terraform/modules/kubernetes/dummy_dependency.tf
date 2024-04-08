locals {
  tags = merge(
    var.grafana_tags,
    {
      "kaito" = "enabled"
    }
  )
}

resource "azapi_update_resource" "update_grafana_tags" {
  count       = var.kaito_enabled ? 1 : 0
  type        = "Microsoft.Dashboard/grafana@2023-09-01"
  resource_id = var.grafana_id

  body = jsonencode({
    properties = {
      tags = local.tags
    }
  })
}