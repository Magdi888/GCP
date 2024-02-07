variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "vpc_name" {
  type = string
}

variable "subnets" {
  type = list(string)

}
variable "subnet_cidr" {
  type    = list(string)
  default = ["10.10.0.0/16"] // Default to single subnet with /16 cidr if not provided
}

variable "cluster_name" {
  description = "The name for the GKE cluster"
  default     = "gke-terraform"
}
variable "env_name" {
  description = "The environment for the GKE cluster"
  default     = "dev"
}

variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}
variable "ip_range_pods" {
  description = "The secondary ip range to use for pods"
  default     = "10.20.0.0/16"
}

variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-services"
}

variable "ip_range_services" {
  description = "The secondary ip range to use for services"
  default     = "10.30.0.0/16"
}


variable "machine_type" {
  type    = string
  default = "n2-standard-2"
}

variable "minnode" {
  type = number
}

variable "maxnode" {
  type = number
}

variable "disksize" {
  type = number
}

variable "initial_node_count" {
  type = number
}

variable "disk_type" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "control_machine_type" {
  type = string
}

variable "bootdisk_type" {
  type = string
}

variable "bootdisk_size" {
  type = string
}

variable "Devops_cidr" {
  type = string
}