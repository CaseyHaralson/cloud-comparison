#!/bin/sh

# fail if any called scripts fail
set -e

echo ""
echo "cloud-run.job.db-migration script: run container as the db migration job..."
echo "(this step calls 'gcloud' as your user so may require reauthentication)"
echo ""

# include terraform values
. ./cloud-run.get-terraform-values.sh
. ./cloud-run.get-infra-terraform-values.sh

JOB=db-migration-job$GCP_PROJECT_RESOURCE_NAMING_SUFFIX

# check to see if the job already exists, and delete it if does
JOB_EXISTS=`gcloud run jobs list --filter="$JOB" --region="$GCP_CLOUDRUN_SERVICE_LOCATION" | grep "$JOB" || echo ""`
if [ ! -z "$JOB_EXISTS" ]; then
  echo "The job already exists so it will be deleted, recreated with the current container, and then run."
  gcloud run jobs delete "$JOB" --region="$GCP_CLOUDRUN_SERVICE_LOCATION"

  # sleep for a few seconds because the job can still fail the create command
  sleep 5
fi

# shorten some variable names
PGUSER=$GCP_CLOUDSQL_USER_SECRET_NAME
PGPASSWORD=$GCP_CLOUDSQL_PASSWORD_SECRET_NAME
SERVER_CERT=$GCP_CLOUDSQL_SERVER_CA_CERT_SECRET_NAME
CLIENT_KEY=$GCP_CLOUDSQL_CLIENT_CERT_KEY_SECRET_NAME
CLIENT_CERT=$GCP_CLOUDSQL_CLIENT_CERT_SECRET_NAME

# load the built artifact as a cloud run job
# and run the correct script
gcloud run jobs create "$JOB" \
  --image=gcr.io/"$GCP_PROJECT_ID"/"$GCP_CLOUDRUN_ARTIFACT_REPO_ID"/"$GCP_CLOUDRUN_SERVICE" \
  --region="$GCP_CLOUDRUN_SERVICE_LOCATION" \
  --vpc-connector="$GCP_VPC_SERVERLESS_CONNECTOR" \
  --set-env-vars=PGHOST="$GCP_CLOUDSQL_SERVER_IP" \
  --set-secrets=PGUSER="$PGUSER":latest,PGPASSWORD="$PGPASSWORD":latest,PGHOST_CA_CERT="$SERVER_CERT":latest,PGCLIENT_KEY="$CLIENT_KEY":latest,PGCLIENT_CERT="$CLIENT_CERT":latest \
  --command="/usr/local/bin/npm" \
  --args="run","db:migration:run" \
  --execute-now
