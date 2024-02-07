module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = "${var.vpc_name}-${var.env_name}"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${var.subnets[0]}-${var.env_name}"
      subnet_ip             = var.subnet_cidr[0]
      subnet_region         = var.region
      subnet_private_access = "true"
    },

  ]

  secondary_ranges = {
    "${var.subnets[0]}-${var.env_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = var.ip_range_pods
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = var.ip_range_services
      }
    ]
  }

}

# module "cloud-nat" {
#   source     = "terraform-google-modules/cloud-nat/google"
#   version    = "~> 5.0"
#   project_id = var.project_id
#   region     = var.region
#   create_router	 = true
#   router     = "cloud-router"
#   source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
#   subnetworks  = [
#         {
#             name = module.vpc.subnets_names[0]
#             source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
#             secondary_ip_range_names = ["${var.ip_range_pods_name}", "${var.ip_range_services_name}"]
#         },
#   ]
#   log_config_enable	= true
#   log_config_filter = "ERRORS_ONLY"
# }
module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"
  name    = "my-cloud-router"
  project = var.project_id
  network = module.vpc.network_name
  region  = var.region

  nats = [{
    name                               = "nat-gateway"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetworks = [
      {
        name                     = module.vpc.subnets_names[0]
        source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
        secondary_ip_range_names = ["${var.ip_range_pods_name}", "${var.ip_range_services_name}"]
      }
    ]
  }]
}
