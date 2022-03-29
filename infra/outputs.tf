output "cnrm_service_account" {
  value = google_service_account.service_account_cnrm.email
}

output "cluster_name" {
  value = google_container_cluster.cluster.name
}

output "cluster_location" {
  value = google_container_cluster.cluster.location
}
