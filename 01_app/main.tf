# resource "kubernetes_namespace" "example" {
#   metadata {
#     annotations = {
#       name = "example-annotation"
#     }

#     labels = {
#       mylabel = "label-value"
#     }

#     name = "terraform-example-namespace"
#   }
# }

resource "helm_release" "eso" {
  name             = "external-secrets"
  namespace        = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.6.1"
  timeout          = 300
  atomic           = true
  create_namespace = true
  verify = false
  depends_on = [ module.my-app-workload-identity ]
}

module "my-app-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name                = "${var.project_id}.svc.id.goog[external-secrets/external-secrets]"
  namespace           = "external-secrets"
  use_existing_k8s_sa = true
  cluster_name        = "${var.cluster_name}-${var.env_name}"
  location            = var.zones[0]
  project_id          = var.project_id
  roles               = ["roles/secretmanager.secretAccessor"]
  annotate_k8s_sa     = true
}

