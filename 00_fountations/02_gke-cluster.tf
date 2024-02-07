module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                 = var.project_id
  name                       = "${var.cluster_name}-${var.env_name}"
  regional                   = false
  region                     = var.region
  zones                      = [var.zones[0]]
  network                    = module.vpc.network_name
  subnetwork                 = module.vpc.subnets_names[0]
  ip_range_pods              = var.ip_range_pods_name
  ip_range_services          = var.ip_range_services_name
  kubernetes_version         = var.k8s_version
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  grant_registry_access      = true
  master_ipv4_cidr_block     = "10.0.0.0/28"
  enable_private_endpoint    = true
  enable_private_nodes       = true
  remove_default_node_pool   = true
  deletion_protection        = false
  master_authorized_networks = [
    { cidr_block   = var.subnet_cidr[0]
      display_name = "Main Office"
    },
    { cidr_block   = "41.65.83.130/32"
      display_name = "DevOps"
    },
  ]
  node_pools = [
    {
      name               = "node-pool"
      machine_type       = var.machine_type
      image_type         = "COS_CONTAINERD"
      node_locations     = var.zones[0]
      min_count          = var.minnode
      max_count          = var.maxnode
      disk_size_gb       = var.disksize
      disk_type          = var.disk_type
      preemptible        = false
      auto_repair        = false
      auto_upgrade       = true
      initial_node_count = var.initial_node_count
      service_account    = google_service_account.gke_service_account.email
    },
  ]
  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  node_pools_tags = {
    all = ["gke-nodes", ]
  }

}

resource "google_service_account" "gke_service_account" {
  account_id   = "gke-account"
  display_name = "gke_service_account"
}


## role to can pull images from GCR
resource "google_project_iam_member" "k8s_roles" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}