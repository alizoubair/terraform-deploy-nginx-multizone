#! /bin/bash

PROJECT_ID=$1

BUCKET_NAME=tf-backend-gce-$(gcloud projects list --filter project_id="${PROJECT_ID}" --format="value(projectNumber)")

gcloud storage buckets describe gs://"${BUCKET_NAME}"
status=$?
if [ $status -eq 0 ]; then
    echo "bucket exists"
else
    echo "bucket does not exist. Creating bucket by gcloud command."
    gcloud storage buckets create gs://"${BUCKET_NAME}"
fi