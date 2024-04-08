resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }

  depends_on = [azapi_update_resource.update_grafana_tags]
}

resource "kubectl_manifest" "service_account" {
  yaml_body = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: ${var.service_account_name}
      namespace: ${var.namespace}
      annotations:
        azure.workload.identity/client-id: ${var.workload_managed_identity_client_id}
        azure.workload.identity/tenant-id: ${var.tenant_id}
      labels:
        azure.workload.identity/use: "true"
    EOF

  depends_on = [kubernetes_namespace.namespace]
}