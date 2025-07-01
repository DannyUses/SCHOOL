# main.tf

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Private GKE Autopilot Cluster
module "gke" {
  source               = "terraform-google-modules/kubernetes-engine/google//modules/autopilot-private-cluster"
  project_id           = var.project_id
  name                 = "hipaa-gke"
  region               = var.region
  enable_private_nodes = true

  # CMEK for node encryption (requires a KMS key)
  # The GKE module doesn't directly expose a parameter for node disk CMEK.
  # Node disk encryption with CMEK is configured at the project level or
  # through specific disk configurations. For Autopilot, node disks are
  # ephemeral and managed by Google.
  # However, for control plane secrets and persistent volumes, you'd use CMEK.
  # We will define a KMS Key Ring and Key below and ensure they are used
  # for relevant services where applicable (e.g., persistent volumes if you add them).
  # For Autopilot, the default disk encryption is Google-managed, but you can use
  # customer-managed encryption keys (CMEK) for persistent disks attached to pods.
  # This module focuses on the cluster itself.
  # We will provision a KMS key that can be used for PVs or other services.
}

# Create a KMS Key Ring for GKE Control Plane Secrets and Persistent Volumes
resource "google_kms_key_ring" "gke_key_ring" {
  name     = "hipaa-gke-keyring"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "gke_key" {
  name            = "hipaa-gke-key"
  key_ring        = google_kms_key_ring.gke_key_ring.id
  rotation_period = "100000s" # Example rotation period, adjust as needed

  lifecycle {
    prevent_destroy = true # Prevent accidental deletion of the key
  }
}

# 2. Cloud SQL with HA (MySQL 8.0)
resource "google_sql_database_instance" "mysql_instance" {
  database_version = "MYSQL_8_0"
  name             = "hipaa-mysql-instance"
  project          = var.project_id
  region           = var.region
  settings {
    tier = var.sql_tier

    # High Availability (Multi-zone)
    backup_configuration {
      enabled            = true
      binary_log_enabled = true # Required for point-in-time recovery
      start_time         = "03:00" # Example backup window
      location           = var.region # Backup location
    }

    ip_configuration {
      ipv4_enabled = true
      # Restrict authorized networks for security
      authorized_networks {
        value = "0.0.0.0/0" # WARNING: This allows access from anywhere. Restrict this to your VPC or specific IPs.
        # To make it truly private and secure, use Private IP only and VPC Peering.
        # For a truly HIPAA-compliant setup, you should use Private IP with Private Service Connect
        # or VPC Peering to restrict access to your GKE cluster's VPC.
      }
    }

    disk_autoresize     = true
    disk_autoresize_limit = 0 # No limit
    disk_size           = 20 # GB
    disk_type           = "PD_SSD"

    # For High Availability, create a read replica in another zone (implicit multi-zone HA with failover)
    # The primary instance is implicitly highly available across zones when `availability_type` is `REGIONAL`.
    # As of Terraform Google Provider v5.0+, the `replica_configuration` block for read replicas is part of the `google_sql_database_instance`
    # resource itself, but high availability for the *primary* instance is handled by `availability_type = "REGIONAL"`.
    availability_type = "REGIONAL"

    # CMEK for Cloud SQL (requires a KMS key)
    disk_encryption_configuration {
      kms_key_name = google_kms_crypto_key.sql_key.id
    }
  }
}

# Create a KMS Key Ring for Cloud SQL
resource "google_kms_key_ring" "sql_key_ring" {
  name     = "hipaa-sql-keyring"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "sql_key" {
  name            = "hipaa-sql-key"
  key_ring        = google_kms_key_ring.sql_key_ring.id
  rotation_period = "100000s" # Example rotation period

  lifecycle {
    prevent_destroy = true # Prevent accidental deletion of the key
  }
}

# 3. CMEK-Enabled Cloud Storage Bucket
resource "google_storage_bucket" "hipaa_archives_bucket" {
  name                        = "${var.project_id}-hipaa-archives" # Bucket names must be globally unique
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  storage_class               = "COLDLINE"

  # CMEK for Cloud Storage (requires a KMS key)
  encryption {
    default_kms_key_name = google_kms_crypto_key.storage_key.id
  }

  force_destroy = false # Set to true to allow Terraform to destroy non-empty buckets
}

# Create a KMS Key Ring for Cloud Storage
resource "google_kms_key_ring" "storage_key_ring" {
  name     = "hipaa-storage-keyring"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "storage_key" {
  name            = "hipaa-storage-key"
  key_ring        = google_kms_key_ring.storage_key_ring.id
  rotation_period = "100000s" # Example rotation period

  lifecycle {
    prevent_destroy = true # Prevent accidental deletion of the key
  }
}
