variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "atomic-sled-476702-s8"
}

variable "region" {
  description = "GCP region (for Artifact Registry and GKE)"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone (if using zonal cluster). If using regional cluster, set to null."
  type        = string
  default     = "us-central1-a"
}

variable "gke_cluster_name" {
  type    = string
  default = "sre-lab-cluster"
}

variable "artifact_repo_name" {
  type    = string
  default = "bookstore-repo"
}

variable "gke_node_count" {
  type    = number
  default = 2
}

variable "gke_machine_type" {
  type    = string
  default = "e2-medium"  # free-tier friendly-ish; change if you need more
}
