resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "56.6.2"
  timeout          = 300
  atomic           = true
  create_namespace = true
  verify           = false
  values = [
    <<YAML
    coreDns:
      enabled: true
      service:
        enabled: true
        port: 10054
        targetPort: 10054
    prometheus:
      prometheusSpec:
        storageSpec:
          volumeClaimTemplate:
            spec:
              accessModes: ["ReadWriteOnce"]
              resources:
                requests:
                  storage: 1Gi
        serviceMonitorSelectorNilUsesHelmValues: false
        serviceMonitorSelector: {}
        serviceMonitorNamespaceSelector: {}

    grafana:
      persistence:
        enabled: true
        accessMode: ReadWriteMany
        size: 1Gi
        finalizers:
          - kubernetes.io/pvc-protection
      sidecar:
        datasources:
          defaultDatasourceEnabled: true
      additionalDataSources:
        - name: Loki
          type: loki
          url: http://loki-loki-distributed-query-frontend.monitoring:3100
    YAML
  ]
}

resource "google_storage_bucket" "logging" {
  name = "loki-for-logging"
  location = "US"
}

resource "google_service_account" "logging_service_account" {
  account_id   = "loki-sa"
  display_name = "logging_service_account"
}

resource "google_storage_bucket_iam_member" "logging" {
  bucket = google_storage_bucket.logging.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.logging_service_account.email}"
  depends_on = [ google_service_account.logging_service_account, google_storage_bucket.logging ]
}

resource "google_project_iam_member" "workload-identity-role" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${var.project_id}.svc.id.goog[${var.observability-namespace}/loki-sa]"
  depends_on = [ google_service_account.logging_service_account, google_storage_bucket_iam_member.logging ]
}

# module "loki-workload-identity" {
#   source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
#   name                = google_service_account.logging_service_account.account_id
#   namespace           = "monitoring"
#   use_existing_k8s_sa = true
#   use_existing_gcp_sa = true
#   cluster_name        = "${var.cluster_name}-${var.env_name}"
#   location            = var.zones[0]
#   project_id          = var.project_id
#   annotate_k8s_sa     = true
#   module_depends_on   = [helm_release.loki]
#   depends_on = [ google_service_account.logging_service_account ]

# }

resource "helm_release" "loki" {
  name       = "loki"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  version    = "0.78.2"
  timeout    = 300
  atomic     = true
  verify     = false
  values = [
    "${file("loki-values.yaml")}"
  ]
  depends_on = [ google_storage_bucket_iam_member.logging, google_service_account.logging_service_account, google_storage_bucket.logging ]
}

resource "helm_release" "promtail" {
  name       = "promtail"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.15.5"
  timeout    = 300
  atomic     = true
  verify     = false
  values = [
    <<YAML
    config:
      serverPort: 8080
      clients:
        - url: http://loki-loki-distributed-gateway/loki/api/v1/push
    YAML
  ]
}