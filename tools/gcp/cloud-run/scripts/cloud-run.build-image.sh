#!/bin/sh

echo ""
echo "cloud-run.build-image script: submit container source to cloud build..."
echo "(this step calls 'gcloud' as your user so may require reauthentication)"
echo ""

# include terraform values
. ./cloud-run.get-terraform-values.sh

# submit the source to be built
# gcloud builds submit "gs://bucket/object.zip" --tag=gcr.io/my-project/image
gcloud builds submit "$GCP_CLOUDRUN_SOURCE" --tag=gcr.io/"$GCP_PROJECT_ID"/"$GCP_CLOUDRUN_ARTIFACT_REPO_ID"/"$GCP_CLOUDRUN_SERVICE"
