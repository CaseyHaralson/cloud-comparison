#!/bin/sh

echo ""
echo "cloud-run.set-terraform-container-image-value script: find and set the current container image (defaults to hello world if this is the first version)..."
echo "(this step calls 'gcloud' as your user so may require reauthentication)"
echo ""

CONTAINER_IMAGE="gcr.io/google-samples/hello-app:1.0"

# get the current run service name from the terraform output
GCP_CLOUDRUN_SERVICE=`terraform -chdir=../ output | grep cloudrun_service_name | sed -e 's#cloudrun_service_name##' -e 's#=##' | xargs`

# if we got a run service name that means that terraform has been run
# so find the current container image
# (there can be multiple locations, so just take one location and check that container's image
# because the containers should all be replicas of each other)
if [ ! -z $GCP_CLOUDRUN_SERVICE ]
  then
    GCP_CLOUDRUN_SERVICE_LOCATION=`terraform -chdir=../ output -json cloudrun_service_locations | jq '.[0]' | sed 's#"##g'`

    CONTAINER_IMAGE=`gcloud run services describe $GCP_CLOUDRUN_SERVICE --region=$GCP_CLOUDRUN_SERVICE_LOCATION | grep Image | sed -e 's#Image:##' | xargs`
fi

# set the image
sed -i -e 's#_CONTAINER_IMAGE_#'$CONTAINER_IMAGE'#g' ../cloud-run.variables.tf
