resource "kubernetes_namespace" "onlineboutique" {
  metadata {
    name = "onlineboutique"
  }
}

resource "kubernetes_manifest" "app-chart" {
    manifest = yamldecode(
        <<YAML
        apiVersion: argoproj.io/v1alpha1
        kind: Application
        metadata:
          name: onlineboutique
          namespace: argocd
        spec:
          project: default
          source:
            repoURL: us-docker.pkg.dev/online-boutique-ci/charts
            chart: onlineboutique
            targetRevision: 0.9.0
            helm:
                releaseName: onlineboutique
                values: |
                  frontend:
                    externalService: false
          destination:
            server: https://kubernetes.default.svc
            namespace: onlineboutique
          syncPolicy:
            automated:
                prune: true
                selfHeal: true
                allowEmpty: false
            syncOptions:
                - CreateNamespace=true
                - PurnLast=true

            retry:
                limit: 5
                    
        YAML
    )
  depends_on = [ kubernetes_namespace.onlineboutique ]
}


resource "kubernetes_ingress_v1" "frontend" {
    metadata {
      name = "frontend"
      namespace = "onlineboutique"
      annotations = {
        "cert-manager.io/cluster-issuer": "letsencrypt-prod"
      }
    }
    spec {
        ingress_class_name = "nginx"
        tls {
          hosts       = ["dev.demosmenu.com"]
          secret_name = "dev-demosmenu-com-tls"
        }
        rule {
          host = "dev.demosmenu.com"
          http {
            path {
              path = "/"
              backend {
                service {
                  name = "frontend"
                  port {
                    number = 80
                  }
                }
              }
            }
          }
        }
    }
  depends_on = [ kubernetes_manifest.app-chart, kubernetes_namespace.onlineboutique ]

}

