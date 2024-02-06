project_id = "gitops-project-408111"

region = "us-central1"

zones = ["us-central1-a", "us-central1-b"]

vpc_name = "vpc"

subnets =  ["subnet01", "subnet02"]
subnet_cidr = ["10.10.0.0/16", "10.0.0.0/16"]

cluster_name = "gke-cluster"

env_name = "dev"


ip_range_pods_name = "ip-range-pods"

ip_range_pods = "10.20.0.0/16"

ip_range_services_name  = "ip-range-services"

ip_range_services = "10.30.0.0/16"

machine_type = "n2-standard-2"
minnode = 3
maxnode = 6
initial_node_count = 3
disksize = 50
disk_type = pd-standard 