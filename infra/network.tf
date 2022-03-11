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

resource "google_compute_network" "vpc-network" {
  name                    = "network-1"
  project                 = google_project.cymbal-infra-project.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "consumer-subnet" {
  name                     = "subnet-euw2"
  project                  = google_project.cymbal-infra-project.project_id
  region                   = var.region
  network                  = google_compute_network.vpc-network.id
  private_ip_google_access = true
  ip_cidr_range            = "10.1.0.0/22"
}

resource "google_compute_router" "nat_router" {
  name    = "${var.prefix}-nat-rtr"
  project = google_project.cymbal-infra-project.project_id
  region  = var.region
  network = google_compute_network.vpc-network.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gateway" {
  project = google_project.cymbal-infra-project.project_id
  name    = "${var.prefix}-nat-gw"
  router  = google_compute_router.nat_router.name
  region  = var.region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "AUTO_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.consumer-subnet.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

}