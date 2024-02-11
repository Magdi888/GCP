terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
  }
  backend "gcs" {
    bucket = "backendstate"
    prefix = "terraform/03_app"
  }
}



provider "google" {
  project     = var.project_id
  credentials = file("/home/ahmed/.config/gcloud/application_default_credentials.json")
  region      = var.region
}



data "google_container_cluster" "default" {
  name     = "${var.cluster_name}-${var.env_name}"
  location = var.zones[0]
}

provider "kubernetes" {
  host               = "https://${data.google_container_cluster.default.endpoint}"
  client_certificate = base64decode(data.google_container_cluster.default.master_auth[0].client_certificate)
  client_key         = base64decode(data.google_container_cluster.default.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.default.master_auth[0].cluster_ca_certificate
  )
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = []
    command     = "gke-gcloud-auth-plugin"
  }
}

provider "helm" {
  kubernetes {
    host = "https://${data.google_container_cluster.default.endpoint}"
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.default.master_auth[0].cluster_ca_certificate
    )
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = []
      command     = "gke-gcloud-auth-plugin"
    }
  }
}

