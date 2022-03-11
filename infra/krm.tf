# Copyright 2019 Google LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#    http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


/*
    This terraform file sets up the Config Connector service account, this account is used to provision resources
    for demo purposes it's given owner, but in reality you would create a custom role with permissions to CRUD resources
*/

resource "google_service_account" "service_account_cnrm" {
  project      = google_project.cymbal-infra-project.project_id
  account_id   = "${var.prefix}-cnrm-${random_id.postfix.hex}"
  display_name = "${var.prefix}-cnrm-${random_id.postfix.hex}"
}

resource "google_project_iam_binding" "cnrm-project-0" {
  project = google_project.cymbal-infra-project.project_id
  role    = "roles/owner"

  members = [
    "serviceAccount:${google_service_account.service_account_cnrm.email}",
  ]
}

// Allow workload identitiy access to use the service account in the pool.
resource "google_project_iam_binding" "cnrm-project-1" {
  project = google_project.cymbal-infra-project.project_id
  role    = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_project.cymbal-infra-project.project_id}.svc.id.goog[cnrm-system/cnrm-controller-manager]",
  ]
}
