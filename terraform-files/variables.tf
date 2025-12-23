variable "project_id" {
  description = "The ID of the Google Cloud Project."
  type        = string
  default     = "spring-boot-ci-cd-deployment"
}

variable "region" {
  description = "The GCP region for the Cloud Run service."
  type        = string
  default     = "europe-west3"
}

variable "repository_name" {
  description = "The name for the Artifact Registry Docker repository."
  type        = string
  default     = "my-docker-repo"
}

variable "service_name" {
  description = "The name for the Cloud Run service."
  type        = string
  default     = "spring-boot-tf-gcp-sample"
}

variable "app_image_tag" {
  type        = string
  description = "The full path to the docker image"
  default     = "1.0.0"
}