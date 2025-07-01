# HIPAA-Compliant GCP Infrastructure Deployment with Terraform

This repository contains Terraform configurations to deploy a foundational HIPAA-compliant infrastructure on Google Cloud Platform. The infrastructure includes:

- **Private GKE Autopilot Cluster:** For containerized application deployment, leveraging Autopilot for automated cluster management and private nodes for enhanced security.
- **Cloud SQL for MySQL (8.0) with High Availability:** A managed relational database service with multi-zone deployment and automated backups for data durability and availability.
- **CMEK-Enabled Cloud Storage Bucket:** For secure archiving of data, utilizing Customer-Managed Encryption Keys (CMEK), uniform bucket-level access, and Coldline storage class for cost-effective long-term storage.

## Prerequisites

Before you begin, ensure you have the following:

1.  **Google Cloud Project:** A GCP project with billing enabled.
2.  **GCP CLI (gcloud):** Authenticated and configured with your project.
    ```bash
    gcloud auth login
    gcloud config set project YOUR_PROJECT_ID
    ```
3.  **Terraform:** Installed on your local machine (version 1.0 or higher recommended).
    [Download Terraform](https://www.terraform.io/downloads.html)

## Deployment Steps

Follow these steps to deploy the infrastructure:

### 1. Clone the Repository

```bash
git clone [https://github.com/YOUR_USERNAME/hipaa-compliant-gcp-infra.git](https://github.com/YOUR_USERNAME/hipaa-compliant-gcp-infra.git)
cd hipaa-compliant-gcp-infra
