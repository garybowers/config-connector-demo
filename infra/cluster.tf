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

resource "random_id" "postfix" {
  byte_length = 4
}

resource "google_service_account" "service_account" {
  project      = google_project.cymbal-infra-project.project_id
  account_id   = "${var.prefix}-cluster-${random_id.postfix.hex}"
  display_name = "${var.prefix}-cluster-${random_id.postfix.hex}"
}

// setup IAM for logging
resource "google_project_iam_member" "service_account_log_writer" {
  project = google_project.cymbal-infra-project.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "service_account_metric_writer" {
  project = google_project.cymbal-infra-project.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "service_account_monitoring_viewer" {
  project = google_project.cymbal-infra-project.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}


// setup GKE firewall rules

resource "google_compute_firewall" "egress-allow-gke-node" {
  project = google_project.cymbal-infra-project.project_id
  network = google_compute_network.vpc-network.self_link

  name = "${var.prefix}-gke-node-allow-egress-${random_id.postfix.hex}"

  priority  = "200"
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443", "9443", "10250", "15017", "6443"]
  }

  destination_ranges      = ["172.16.0.32/28"]
  target_service_accounts = [google_service_account.service_account.email]
}

resource "google_compute_firewall" "ingress-allow-gke-node" {
  project = google_project.cymbal-infra-project.project_id
  network = google_compute_network.vpc-network.self_link

  name = "${var.prefix}-gke-node-allow-ingress-${random_id.postfix.hex}"

  priority  = "200"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443", "9443", "10250", "15017", "6443"]
  }

  source_ranges           = ["172.16.0.32/28"]
  source_service_accounts = [google_service_account.service_account.email]
}

// setup GKE Cluster

resource "google_container_cluster" "cluster" {
  provider = google-beta

  project  = google_project.cymbal-infra-project.project_id
  name     = "${var.prefix}-cluster-${random_id.postfix.hex}"
  location = var.region

  network    = google_compute_network.vpc-network.name
  subnetwork = google_compute_subnetwork.consumer-subnet.name

  release_channel {
    channel = "REGULAR"
  }

  remove_default_node_pool = true
  initial_node_count       = 1
  enable_shielded_nodes    = true
  enable_legacy_abac       = false
  //enable_autopilot =  true

  node_config {
    labels = {
      private-pool = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = "true"
      enable_integrity_monitoring = "true"
    }

    preemptible = false

    service_account = google_service_account.service_account.email
  }

  workload_identity_config {
    workload_pool = "${google_project.cymbal-infra-project.project_id}.svc.id.goog"

  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.32/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "subnet"
    }
  }

  addons_config {
    config_connector_config {
      enabled = true
    }
  }

  depends_on = [
    google_compute_firewall.egress-allow-gke-node,
    google_compute_firewall.ingress-allow-gke-node,
  ]
}

resource "google_container_node_pool" "nodepools" {
  provider = google-beta
  project  = google_project.cymbal-infra-project.project_id

  cluster     = google_container_cluster.cluster.name
  location    = var.region
  name_prefix = "${var.prefix}-np-"

  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = "e2-medium"

    disk_size_gb = 80
    disk_type    = "pd-balanced"

    preemptible = false

    metadata = {
      disable-legacy-endpoints = true
    }

    labels = {
      private-pool = true
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
    service_account = google_service_account.service_account.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  timeouts {
    create = "30m"
    update = "40m"
    delete = "2h"
  }

}
