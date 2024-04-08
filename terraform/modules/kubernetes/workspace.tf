resource "kubectl_manifest" "kaito_workspace" {
  count = var.kaito_enabled ? 1 : 0

  yaml_body = <<-EOF
    apiVersion: kaito.sh/v1alpha1
    kind: Workspace
    metadata:
      name: workspace-falcon-7b-instruct
      namespace: ${var.namespace}
      annotations:
        kaito.sh/enablelb: "False"
    resource:
      count: 1
      instanceType: "${var.instance_type}"
      labelSelector:
        matchLabels:
          apps: falcon-7b-instruct
    inference:
      preset:
        name: "falcon-7b-instruct"
    EOF

  depends_on = [kubectl_manifest.service_account]
}