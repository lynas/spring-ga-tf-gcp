# Enable Artifact registry api to upload Application docker image
resource "google_project_service" "artifact_registry_api" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# Enable Run api to deploy application
resource "google_project_service" "cloud_run_api" {
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Create Artifact registry repo where application docker image will be uploaded
resource "google_artifact_registry_repository" "docker_repo" {
  provider      = google
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_name
  format        = "DOCKER"
  description   = "Docker repository for Cloud Run images"

  depends_on = [google_project_service.artifact_registry_api]
}

locals {
  image_uri = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_name}/${var.service_name}:${var.app_image_tag}"
}
# # Cloud_Run resource that deploy the application
# resource "google_cloud_run_v2_service" "spring_boot_app" {
#   name                = "spring-boot-service"
#   location            = var.region
#   deletion_protection = false
#
#   template {
#     containers {
#       image = local.image_uri
#       # ports { # enable this if application is running any port other than 8080
#       #   container_port = 9090
#       # }
#       resources {
#         limits = {
#           cpu    = "1"
#           memory = "2Gi"
#         }
#       }
#     }
#
#     scaling {
#       min_instance_count = 0
#       max_instance_count = 1
#     }
#   }
#   ingress = "INGRESS_TRAFFIC_ALL"
# }
#
# resource "google_cloud_run_v2_service_iam_member" "public_access" {
#   project  = var.project_id
#   location = google_cloud_run_v2_service.spring_boot_app.location
#   name     = google_cloud_run_v2_service.spring_boot_app.name
#   role     = "roles/run.invoker"
#   member   = "allUsers"
#   depends_on = [google_cloud_run_v2_service.spring_boot_app]
# }