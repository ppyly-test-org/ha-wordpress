#/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
NOTRANDOM=${RANDOM}
DIR=${PWD}

echo "SSH key username(must be stated):"
read SSH_USER
if [ -z "$SSH_USER" ]
then
    echo "Missing value!"; exit $ERRCODE;
fi

echo "SSH private key full path(must be stated):"
read FULL_PR_KEYS_PATH
if [ -z "$FULL_PR_KEYS_PATH" ]
then
    echo "Missing value!"; exit $ERRCODE;
fi

echo "Bucket name(default if not stated):"
read BUCKET
if [ -z ${BUCKET} ]
  then
    BUCKET="learning-terraform-bucket"
fi
TERRAFORM_BUCKET="${BUCKET}-${NOTRANDOM}"

echo "Service account name(default if not stated):"
read SERVICE_ACCOUNT_ID
if [ -z ${SERVICE_ACCOUNT_ID} ]
  then
    SERVICE_ACCOUNT_ID="serv-acc"
fi

echo "Type in some alphanumeric gibberish(mandatory):"
read GIBBERISH
if [ -z ${GIBBERISH} ]
  then
    echo "Missing value!"; exit $ERRCODE;
fi
echo $GIBBERISH > gibberish.txt

echo "Domain name(default if not stated):"
read DOMAIN
if [ -z ${DOMAIN} ]
  then
    DOMAIN="ppyly.pp.ua"
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

gcloud services enable \
  secretmanager.googleapis.com \
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
  --role="roles/storage.admin" \
  --user-output-enabled false

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

gcloud projects add-iam-policy-binding \
  "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.instanceAdmin.v1" \
  --user-output-enabled false

gcloud projects add-iam-policy-binding \
  "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/iam.serviceAccountUser" \
  --user-output-enabled false

gcloud projects add-iam-policy-binding \
  "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/iap.tunnelResourceAccessor" \
  --user-output-enabled false

echo "Adding role roles/secretmanager.admin..."
gcloud projects add-iam-policy-binding \
  "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/secretmanager.admin" \
  --user-output-enabled false

FULL_PUB_KEYS_PATH="${FULL_PR_KEYS_PATH}.pub"
SSH_KEY_CONTENT=`cat  ${FULL_PUB_KEYS_PATH}`
echo "${SSH_USER}:${SSH_KEY_CONTENT}" > project_key.txt

gcloud compute project-info add-metadata --metadata-from-file=ssh-keys=project_key.txt
rm project_key.txt

gcloud secrets create gibberish --data-file=gibberish.txt
rm gibberish.txt

echo "Creating envvars.sh"
cat << EOF > envvars.sh
export GOOGLE_APPLICATION_CREDENTIALS="${DIR}/sa-private-key.json"
export TF_VAR_sa=$SA_ID
export TF_VAR_project=$PROJECT_ID
export TF_VAR_bucket=$TERRAFORM_BUCKET
export TF_VAR_ssh_user=$SSH_USER
export TF_VAR_full_pr_keys_path=$FULL_PR_KEYS_PATH
export TF_VAR_domain=$DOMAIN
EOF

salt=$(curl https://api.wordpress.org/secret-key/1.1/salt)
cat $salt > ha-wordpress/packer/wordpress/files/salt.tpl


source envvars.sh

terraform init -backend-config=bucket=$TF_VAR_bucket
