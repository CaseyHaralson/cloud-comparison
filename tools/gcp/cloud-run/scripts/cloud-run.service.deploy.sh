#!/bin/sh

echo ""
echo "cloud-run.service.deploy script: deploy container to cloud run service..."
echo "(this step calls 'gcloud' as your user so may require reauthentication)"
echo ""

# include terraform values
. ./cloud-run.get-terraform-values.sh

# loop through each location
echo $GCP_CLOUDRUN_SERVICE_LOCATIONS | jq -c '.[]' | while read i; do
  LOCATION=`echo $i | sed 's#"##g'`

  # load the built artifact into the cloud run service
  # gcloud run deploy my-backend --image=us-docker.pkg.dev/project/image
  gcloud run deploy "$GCP_CLOUDRUN_SERVICE" --image=gcr.io/"$GCP_PROJECT_ID"/"$GCP_CLOUDRUN_ARTIFACT_REPO_ID"/"$GCP_CLOUDRUN_SERVICE" --region="$LOCATION"
done
