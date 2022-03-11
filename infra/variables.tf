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

variable "folder_id" {
  type        = string
  description = "The folder to deploy the projects to."
}

variable "billing_account" {
  type        = string
  description = "Billing account id"
}

variable "region" {
  type        = string
  description = "Region to deploy resources to (default europe-west2"
  default     = "europe-west2"
}

variable "prefix" {
  type        = string
  description = "Prefix for resources deployed into the project"
  default     = "test"
}

variable "services" {
  description = "list of services to enable in the porject"
  default     = ["container.googleapis.com", "serviceusage.googleapis.com", "sqladmin.googleapis.com"]
}
