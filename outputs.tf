# outputs.tf

output "gke_cluster_name" {
  description = "The name of the deployed GKE Autopilot cluster."
  value       = module.gke.name
}

output "gke_cluster_endpoint" {
  description = "The endpoint of the GKE Autopilot cluster."
  value       = module.gke.endpoint
}

output "sql_instance_connection_name" {
  description = "The connection name of the Cloud SQL instance."
  value       = google_sql_database_instance.mysql_instance.connection_name
}

output "storage_bucket_name" {
  description = "The name of the CMEK-enabled Cloud Storage bucket."
  value       = google_storage_bucket.hipaa_archives_bucket.name
}

output "gke_kms_key_name" {
  description = "The name of the KMS key used for GKE related encryption."
  value       = google_kms_crypto_key.gke_key.id
}

output "sql_kms_key_name" {
  description = "The name of the KMS key used for Cloud SQL encryption."
  value       = google_kms_crypto_key.sql_key.id
}

output "storage_kms_key_name" {
  description = "The name of the KMS key used for Cloud Storage encryption."
  value       = google_kms_crypto_key.storage_key.id
}
