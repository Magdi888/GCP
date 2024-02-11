
resource "helm_release" "eso" {
  name             = "external-secrets"
  namespace        = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.6.1"
  timeout          = 300
  atomic           = true
  create_namespace = true
  verify           = false
}

module "external-secrets-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name                = "external-secrets"
  namespace           = "external-secrets"
  use_existing_k8s_sa = true
  cluster_name        = "${var.cluster_name}-${var.env_name}"
  location            = var.zones[0]
  project_id          = var.project_id
  roles               = ["roles/secretmanager.secretAccessor"]
  annotate_k8s_sa     = true
  module_depends_on   = [helm_release.eso]
}

resource "helm_release" "certm" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.12.0"
  timeout          = 300
  atomic           = true
  create_namespace = true
  verify           = false

  values = [
    <<YAML
    installCRDs: true
    YAML
  ]
}

# module "certm-workload-identity" {
#   source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
#   name                = "cert-manager"
#   namespace           = "cert-manager"
#   use_existing_k8s_sa = true
#   cluster_name        = "${var.cluster_name}-${var.env_name}"
#   location            = var.zones[0]
#   project_id          = var.project_id
#   roles               = ["roles/dns.admin"]
#   annotate_k8s_sa     = true
#   module_depends_on   = [helm_release.cetm]
# }

resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.9.0"
  timeout          = 300
  atomic           = true
  create_namespace = true
  verify           = false

  values = [
    <<YAML
    controller:
      podSecurityContext:
        runAsNonRoot: true
      service:
        enableHttp: true
        enableHttps: true
    YAML
  ]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "6.0.5"
  timeout          = 300
  atomic           = true
  create_namespace = true
  verify           = false
  values = [
    <<YAML
    nameOverride: argocd
    redis-ha:
      enabled: false
    YAML
  ]
}