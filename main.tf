/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


## NOTE: This provides PoC demo environment for various use cases ##
##  This is not built for production workload ##



# Random id for naming
resource "random_string" "id" {
    length  = 4
    upper   = false
    lower   = true
    number  = true
    special = false
    }


# Create Folder in GCP Organization
resource "google_folder" "terraform_solution" {
    display_name    =  "${var.folder_name}"
    parent          = "organizations/${var.organization_id}"
  }

data "google_active_folder" "sf_folder" {
    display_name    =  "${var.folder_name}"
    parent          = "organizations/${var.organization_id}"
    depends_on              = [google_folder.terraform_solution]
}

# Enabling logging at Folder level
  resource "google_folder_iam_audit_config" "config_data_log" {
  folder = data.google_active_folder.sf_folder.id
  service = "allServices"
  audit_log_config {
    log_type = "ADMIN_READ"
 #   exempted_members = [
#      "user:joebloggs@hashicorp.com",
#    ]
  }

  audit_log_config {
    log_type = "DATA_READ"
 #   exempted_members = [
#      "user:abcs@xyz.com",
#    ]
  }

  depends_on              = [data.google_active_folder.sf_folder]
}

module "vpc_sc_deploy" {
    source = "./vpcsc-module"
    folder_id                       = google_folder.terraform_solution.name
    demo_project_id                 = var.demo_project_id
    organization_id                 = var.organization_id
    network_region                  = var.network_region
    network_zone                    = var. network_zone
    random_string                   = random_string.id.result
    billing_account                 = var.billing_account
    proxy_access_identities         = var.proxy_access_identities
    create_default_access_policy    = false
}

