#! /bin/bash

PROJECT_ID=$1

# Sets the Cloud Shell to the project
gcloud config set project $PROJECT_ID

# Creates a new service account
gcloud iam service-accounts create terraform --description="Terraform Service Account" --display-name="terraform"

# Sets the service account 
export GOOGLE_SERVICE_ACCOUNT=`gcloud iam service-accounts \
list --format="value(email)" --filter=name:"terraform@"`

# Sets the roles required to the new service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin.v1"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/secretmanager.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/serviceusage.serviceUsageAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/servicenetworking.networksAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/resourcemanager.projectIamAdmin"

# Creates service account key
if [ -e ../infra/key.json ]; then
    echo "Key already exists"
else
    gcloud iam service-accounts keys create "../infra/key.json" \
    --iam-account=$GOOGLE_SERVICE_ACCOUNT
fi
