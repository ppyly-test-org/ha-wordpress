set -e

PROJECT_ID=$(gcloud config get-value project)
NOTRANDOM=${RANDOM}
DIR=${PWD}


echo "Bucket name(default if not stated):"
read BUCKET
if [ -z ${BUCKET} ]
  then
    BUCKET="wordpress-bucket"
fi
TERRAFORM_BUCKET="${BUCKET}-${NOTRANDOM}"

echo "Service account name(default if not stated):"
read SERVICE_ACCOUNT_ID
if [ -z ${SERVICE_ACCOUNT_ID} ]
  then
    SERVICE_ACCOUNT_ID="serv-acc"
fi

SA_ID="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Enabling required API's"
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  --project ${PROJECT_ID}

gcloud services enable \
  iam.googleapis.com \
  --project ${PROJECT_ID}

gcloud services enable \
  admin.googleapis.com \
  --project ${PROJECT_ID}

gcloud services enable \
  compute.googleapis.com \
  --project ${PROJECT_ID}

gcloud services enable \
  sqladmin.googleapis.com \
  --project ${PROJECT_ID}

gcloud services enable \
  servicenetworking.googleapis.com \
    --project=${PROJECT_ID}

gsutil mb -p ${PROJECT_ID} -c regional -l "europe-central2" gs://${TERRAFORM_BUCKET}
gsutil versioning set on gs://${TERRAFORM_BUCKET}

gcloud iam service-accounts create ${SERVICE_ACCOUNT_ID} \
    --description="SAcc" \
    --display-name="SAcc" \
    --project=${PROJECT_ID} 

gcloud iam service-accounts keys create ${DIR}/sa-private-key.json \
    --iam-account=${SA_ID}

echo "Adding role roles/storage.admin..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${SA_ID} \
    --role="roles/storage.admin"


echo "Adding role roles/compute.networkAdmin..."
gcloud projects add-iam-policy-binding \
  "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.networkAdmin" \
  --user-output-enabled false

echo "Adding role roles/resourcemanager.projectIamAdmin..."
gcloud projects add-iam-policy-binding \
  "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectIamAdmin" \
  --user-output-enabled false

echo "Adding role roles/compute.storageAdmin..."
gcloud projects add-iam-policy-binding \
  "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.storageAdmin" \
  --user-output-enabled false

echo "Adding role roles/iam.securityAdmin..."
gcloud projects add-iam-policy-binding \
  "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/iam.securityAdmin" \
  --user-output-enabled false

echo "Adding role roles/compute.admin..."
gcloud projects add-iam-policy-binding \
  "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.admin" \
  --user-output-enabled false

echo "Adding role roles/cloudsql.admin..."
gcloud projects add-iam-policy-binding \
  "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/cloudsql.admin" \
  --user-output-enabled false



echo "Creating envvars.sh"
cat << EOF > envvars.sh
export GOOGLE_APPLICATION_CREDENTIALS="${DIR}/sa-private-key.json"
export TF_VAR_PROJECT_ID=$PROJECT_ID
export TF_VAR_SA=$SERVICE_ACCOUNT_ID
export TF_VAR_project=$PROJECT_ID
export TF_VAR_bucket=$TERRAFORM_BUCKET
EOF

source envvars.sh

terraform init -backend-config=bucket=$TF_VAR_bucket
