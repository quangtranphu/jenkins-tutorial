// Variables to use accross the project
// which can be accessed by var.project_id
variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "inner-replica-469607-h9"
}

variable "region" {
  description = "The region the cluster in"
  default     = "europe-west3"
}

variable "zone" {
  description = "The zone cluster in"
  default = "europe-west3-a"
}

variable "bucket" {
  description = "GCS bucket for MLE course"
  default     = "quangtp-mle-course"
}