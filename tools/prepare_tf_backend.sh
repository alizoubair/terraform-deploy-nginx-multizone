#! /bin/bash

PROJECT_ID=$1

BUCKET_NAME=tf-backend-gce-$(gcloud projects list --filter project_id="${PROJECT_ID}" --format="value(projectNumber)")

# Generate tf_backend.tf by BUCKET_NAME
cat << EOF > ../infra/tf_backend.tf
terraform {
    backend "gcs" {
        bucket = "${BUCKET_NAME}"
        prefix = "app/infra"
    }
}
EOF