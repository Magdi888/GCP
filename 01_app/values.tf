variable "project_id" {
    type = string
}

variable "region" {
    type = string
}

variable "zones" {
    type = list(string)
}

variable "cluster_name" {
  description = "The name for the GKE cluster"
  default     = "gke-terraform"
}
variable "env_name" {
  description = "The environment for the GKE cluster"
  default     = "dev"
}

