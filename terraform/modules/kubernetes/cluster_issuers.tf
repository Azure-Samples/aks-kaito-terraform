resource "kubectl_manifest" "nginx_cluster_issuer" {
  yaml_body = <<-EOF
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-nginx
      namespace: kube-system
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        email: ${var.email}
        privateKeySecretRef:
          name: letsencrypt-nginx
        solvers:
        - http01:
            ingress:
              class: nginx
              podTemplate:
                spec:
                  nodeSelector:
                    "kubernetes.io/os": linux
    EOF

  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "managed_nginx_cluster_issuer" {
  yaml_body = <<-EOF
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-webapprouting
      namespace: kube-system
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        email: ${var.email}
        privateKeySecretRef:
          name: letsencrypt-webapprouting
        solvers:
        - http01:
            ingress:
              class: webapprouting.kubernetes.azure.com
              podTemplate:
                spec:
                  nodeSelector:
                    "kubernetes.io/os": linux
    EOF

  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "dns_cluster_issuer" {
  count     = var.dns_zone_name != null && var.dns_zone_resource_group_name != null ? 1 : 0
  yaml_body = <<-EOF
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-dns
      namespace: kube-system
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        email: ${var.email}
        privateKeySecretRef:
          name: letsencrypt-dns
        solvers:
        - dns01:
            azureDNS:
              resourceGroupName: ${var.dns_zone_resource_group_name}
              subscriptionID: ${var.dns_zone_subscription_id}
              hostedZoneName: ${var.dns_zone_name}
              environment: AzurePublicCloud
              managedIdentity:
                clientID: ${var.certificate_manager_managed_identity_client_id}
    EOF

  depends_on = [helm_release.cert_manager]
}