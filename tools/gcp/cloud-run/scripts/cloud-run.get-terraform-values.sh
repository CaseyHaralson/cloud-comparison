#!/bin/sh

# echo "getting values from terraform..."

if [ -z "$GCP_PROJECT_RESOURCE_NAMING_SUFFIX" ]; then
  GCP_PROJECT_RESOURCE_NAMING_SUFFIX=`terraform -chdir=../ output --raw project_resource_naming_suffix`
fi

if [ -z "$GCP_CLOUDRUN_SOURCE_BUCKET" ]; then
  GCP_CLOUDRUN_SOURCE_BUCKET=`terraform -chdir=../ output --raw cloudrun_source_bucket_url`
fi

if [ -z "$GCP_CLOUDRUN_SOURCE_NAME" ]; then
  GCP_CLOUDRUN_SOURCE_NAME=`terraform -chdir=../ output --raw cloudrun_source_name`
fi

if [ -z "$GCP_CLOUDRUN_SOURCE" ]; then
  GCP_CLOUDRUN_SOURCE="${GCP_CLOUDRUN_SOURCE_BUCKET}/${GCP_CLOUDRUN_SOURCE_NAME}"
fi

if [ -z "$GCP_CLOUDRUN_ARTIFACT_REPO_ID" ]; then
  GCP_CLOUDRUN_ARTIFACT_REPO_ID=`terraform -chdir=../ output --raw cloudrun_artifact_repository_id`
fi

if [ -z "$GCP_CLOUDRUN_SERVICE" ]; then
  GCP_CLOUDRUN_SERVICE=`terraform -chdir=../ output --raw cloudrun_service_name`
fi

if [ -z "$GCP_CLOUDRUN_SERVICE_LOCATIONS" ]; then
  GCP_CLOUDRUN_SERVICE_LOCATIONS=`terraform -chdir=../ output -json cloudrun_service_locations`
fi

# for some things we just need a valid region, so grab the first one
if [ -z "$GCP_CLOUDRUN_SERVICE_LOCATION" ]; then
  GCP_CLOUDRUN_SERVICE_LOCATION=`terraform -chdir=../ output -json cloudrun_service_locations | jq '.[0]' | sed 's#"##g'`
fi

# echo "Resource naming suffix: $GCP_PROJECT_RESOURCE_NAMING_SUFFIX"
# echo "CloudRun source bucket: $GCP_CLOUDRUN_SOURCE_BUCKET"
# echo "CloudRun source name: $GCP_CLOUDRUN_SOURCE_NAME"
# echo "CloudRun source: $GCP_CLOUDRUN_SOURCE"
# echo "CloudRun artifact repo id: $GCP_CLOUDRUN_ARTIFACT_REPO_ID"
# echo "CloudRun service: $GCP_CLOUDRUN_SERVICE"
# echo "CloudRun service location: $GCP_CLOUDRUN_SERVICE_LOCATIONS"
