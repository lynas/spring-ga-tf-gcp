variable "project_id" {
  description = "The ID of the project where services will be enabled"
  type        = string
  default     = "spring-boot-ci-cd-deployment"
}

variable "project_number" {
  description = "The ID of the project where services will be enabled"
  type        = string
  default     = "587038327360"
}

variable "region" {
  description = "The GCP region for the Cloud Run service."
  type        = string
  default     = "europe-west3"
}

variable "github_repo" {
  description = "The GitHub repository in 'owner/repo' format"
  type        = string
  default     = "lynas/spring-ga-tf-gcp"
}

# 1. Enable required API
locals {
  services = [
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  # TODO Change as running locally multiple time
  workload_identity_pool_id = "github-pool-v4"
}

resource "google_project_service" "enabled_services" {
  for_each = toset(local.services)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# 2. Create the Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.project_id
  workload_identity_pool_id = local.workload_identity_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions automation"
  depends_on = [google_project_service.enabled_services]
}

# 3. Create the OIDC Provider within that Pool
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  # This ensures only your specific repository can use this provider
  attribute_condition = "attribute.repository == '${var.github_repo}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [google_iam_workload_identity_pool.github_pool]
}

# 4. Create the Service Account for terraform
resource "google_service_account" "terraform_sa" {
  project      = var.project_id
  account_id   = "terraform-sa"
  display_name = "Terraform Automation Service Account"

  depends_on = [google_iam_workload_identity_pool_provider.github_provider]
}

# 5. Grant Project-Level Roles to the service account
# We use a loop to assign multiple roles to the same Service Account
resource "google_project_iam_member" "sa_roles" {
  for_each = toset([
    "roles/editor",
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"

  depends_on = [google_service_account.terraform_sa]
}

# 6. Allow GitHub to impersonate this Service Account (Workload Identity)
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.terraform_sa.name
  role = "roles/iam.workloadIdentityUser"

  # The member identity must match the principalSet format exactly
  member = "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${local.workload_identity_pool_id}/attribute.repository/${var.github_repo}"

  depends_on = [google_project_iam_member.sa_roles]
}

# 7. GCP bucket to store terraform state file
resource "google_storage_bucket" "terraform_state_bucket" {
  project       = var.project_id
  name          = "terraform-state-bucket-${var.project_id}"
  location      = "europe-west3"
  force_destroy = true # Set to true only if you want Terraform to delete the bucket even if it contains objects

  # 1. Uniform bucket-level access
  uniform_bucket_level_access = true

  # 2. Enable Object Versioning
  versioning {
    enabled = true
  }

  # 3. Prevent public access
  public_access_prevention = "enforced"

  # Optional: Recommended for state buckets to prevent accidental deletion
  lifecycle {
    prevent_destroy = false
  }

  depends_on = [google_service_account_iam_member.workload_identity_user]
}

# 8. Grant the Service Account Object Admin rights on the bucket
resource "google_storage_bucket_iam_member" "sa_storage_admin" {
  bucket = google_storage_bucket.terraform_state_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform_sa.email}"
  depends_on = [google_storage_bucket.terraform_state_bucket]
}