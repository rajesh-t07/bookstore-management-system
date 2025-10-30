output "artifact_repository" {
  value = google_artifact_registry_repository.docker_repo.repository_id
}

output "artifact_repository_location" {
  value = google_artifact_registry_repository.docker_repo.location
}

output "gke_cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "gke_cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

output "gha_service_account_email" {
  value = google_service_account.gha.email
}
