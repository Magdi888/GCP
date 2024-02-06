terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.14.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
  backend "gcs" {
    bucket  = "backendstate"
    prefix  = "terraform/00_foundation"
  }
}



provider "google" {
  project = var.project_id
  credentials = file("/home/ahmed/.config/gcloud/application_default_credentials.json")
  region  = var.region
}

# data "google_client_config" "default" {
#   depends_on = [module.gke-cluster]
# }

# provider "kubernetes" {
#   host                   = module.gke.endpoint
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(module.gke.ca_certificate)
# }
  
