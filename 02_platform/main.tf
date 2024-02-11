data "kubernetes_service_v1" "ingress-nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

resource "google_dns_managed_zone" "demos-zone" {
  name        = "demos-menu"
  dns_name    = "demosmenu.com."
  description = "DNS zone"
}

resource "google_dns_record_set" "ingress-record" {
  name         = "dev.${google_dns_managed_zone.demos-zone.dns_name}"
  managed_zone = google_dns_managed_zone.demos-zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [data.kubernetes_service_v1.ingress-nginx.status.0.load_balancer.0.ingress.0.ip]
}



# data "google_dns_managed_zone" "env_dns_zone" {
#   name = "demosmenu-com"
# }

# resource "google_dns_record_set" "ingress-record" {
#   name         = "dev.${data.google_dns_managed_zone.env_dns_zone.dns_name}"
#   managed_zone = data.google_dns_managed_zone.env_dns_zone.name
#   type         = "A"
#   ttl          = 300
#   rrdatas      = [data.kubernetes_service_v1.ingress-nginx.status.0.load_balancer.0.ingress.0.ip]
# }

resource "kubernetes_manifest" "cert_issuer" {
  manifest = yamldecode(
    <<YAML
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: letsencrypt-prod
      spec:
        acme:
          server: https://acme-v02.api.letsencrypt.org/directory
          email: a.magdi888@gmail.com
          privateKeySecretRef:
            name: letsencrypt-prod
          solvers:
            - http01:
                ingress:
                  ingressClassName: nginx
      YAML
  )
  depends_on = [google_dns_record_set.ingress-record]
}



resource "kubernetes_manifest" "external_secret_store" {
  manifest = yamldecode(
    <<YAML
        apiVersion: external-secrets.io/v1beta1
        kind: ClusterSecretStore
        metadata:
          name: gcp-store
        spec:
            provider:
                gcpsm:
                    projectID: "${var.project_id}"
        YAML
  )
}


