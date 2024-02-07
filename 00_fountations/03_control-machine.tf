data "google_compute_image" "image" {
  family  = "debian-12"
  project = var.project_id
}

resource "google_service_account" "manager_service_account" {
  account_id   = "manager-account"
  display_name = "manager_service_account"
}



resource "google_project_iam_member" "k8s_admin_role" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.manager_service_account.email}"
}

resource "google_compute_instance" "manager-instance" {
  name         = "manager-instance"
  machine_type = var.control_machine_type
  zone         = var.zones[0]

  tags = ["managed-instance"]

  boot_disk {
    initialize_params {
      size = var.bootdisk_size
      type = var.bootdisk_type
      image = data.google_compute_image.image.self_link
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = module.vpc.name
    subnetwork =  module.vpc.subnets[0].subnet_name

    
  }

  
  service_account {
    email  = google_service_account.manager_service_account.email
    scopes = ["cloud-platform"]
  }
  depends_on = [module.vpc, module.gke]

  metadata_startup_script = file("./config_gcloud.sh")

  

}