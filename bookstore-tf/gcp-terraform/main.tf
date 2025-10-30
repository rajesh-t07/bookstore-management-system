# 1) Enable required APIs
resource "google_project_service" "services" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "containeranalysis.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
  ])

  project = var.project_id
  service = each.key

  # ensure order
  disable_on_destroy = false
}

# 2) Artifact Registry (Docker repository)
resource "google_artifact_registry_repository" "docker_repo" {
  provider = google
  project  = var.project_id
  location = var.region
  repository_id = var.artifact_repo_name
  format = "DOCKER"
  description = "Docker repo for bookstore images"
}

# 3) GKE cluster (regional cluster recommended; adjust as needed)
resource "google_container_cluster" "gke_cluster" {
  name     = var.gke_cluster_name
  project  = var.project_id
  location = var.region  # regional cluster

  remove_default_node_pool = true
  initial_node_count = 1

  # basic auth disabled, use IAM/GKE auth
  master_auth {
    username = "" # disable basic auth
    password = ""
  }

  ip_allocation_policy { } # enable VPC-native (recommended)

  # network & subnetwork can be default for simplicity
}

# Node pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  cluster    = google_container_cluster.gke_cluster.name
  project    = var.project_id
  location   = var.region

  node_count = var.gke_node_count

  node_config {
    machine_type = var.gke_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    # You could set labels, taints, and metadata if required
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# 4) Service account for GitHub Actions
resource "google_service_account" "gha" {
  account_id   = "github-actions-sre"
  project      = var.project_id
  display_name = "GitHub Actions service account for CI/CD"
}

# 5) IAM bindings for the SA (least-privilege-ish)
# Grant push to Artifact Registry
resource "google_project_iam_member" "artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.gha.email}"
}

# Allow the SA to interact with GKE (container developer)
resource "google_project_iam_member" "gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.gha.email}"
}

# Optionally, allow SA to impersonate other SA if you plan to do that
resource "google_project_iam_member" "iam_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.gha.email}"
}

# (Optional) Grant storage admin if you will use GCS for artifacts, etc.
resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.gha.email}"
}
