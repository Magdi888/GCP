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