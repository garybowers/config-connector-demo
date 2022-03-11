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

resource "random_integer" "project_salt" {
  min = 100000
  max = 999999
}
/*
resource "google_project" "cymbal-infra-project" {
  provider            = google.core
  name                = "cloud-dev-cymbal-coffee"
  project_id          = "cymbal-coffee-infra-${random_integer.project_salt.result}"
  auto_create_network = false
  folder_id           = var.folder_id
  billing_account     = var.billing_account
}
*/

resource "google_project_service" "project_apis" {
  project = var.project_id
  count   = length(var.services)
  service = element(var.services, count.index)

  disable_dependent_services = true
  disable_on_destroy         = true
}
