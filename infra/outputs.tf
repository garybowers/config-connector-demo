output "project_id" {
    value = google_project.cymbal-infra-project.project_id
}

output "cnrm_service_account" {
    value = google_service_account.service_account_cnrm.email
}