
# Global Variables
project_id = "gitops-project-408111"
region = "us-central1"
zones = ["us-central1-a", "us-central1-b"]
vpc_name = "vpc"
subnets =  ["subnet01", "subnet02"]
subnet_cidr = ["10.10.0.0/16", "10.0.0.0/16"]
env_name = "dev"

# GKE Cluster Variables
cluster_name = "gke-cluster"
ip_range_pods_name = "ip-range-pods"
ip_range_pods = "10.20.0.0/16"
ip_range_services_name  = "ip-range-services"
ip_range_services = "10.30.0.0/16"
machine_type = "n2-standard-2"
minnode = 3
maxnode = 6
initial_node_count = 3
disksize = 50
disk_type = "pd-standard"
k8s_version = "1.29"

# Control Machine  Variables

control_machine_type = "n1-standard-1"
bootdisk_type = "pd-standard"
bootdisk_size = 10

