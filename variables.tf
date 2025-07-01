# variables.tf

variable "project_id" {
  description = "The GCP project ID where resources will be deployed."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources in (e.g., us-central1)."
  type        = string
  default     = "us-central1" # Example default region
}

variable "sql_tier" {
  description = "The machine type for the Cloud SQL instance (e.g., db-f1-micro, db-n1-standard-1)."
  type        = string
  default     = "db-n1-standard-1" # Recommended for production, adjust as needed
}
