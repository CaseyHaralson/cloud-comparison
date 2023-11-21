#!/bin/sh

# =====================================
#         detect sourcing

# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
sourced=0
if [ -n "$ZSH_VERSION" ]; then 
  case $ZSH_EVAL_CONTEXT in *:file) sourced=1;; esac
elif [ -n "$KSH_VERSION" ]; then
  [ "$(cd -- "$(dirname -- "$0")" && pwd -P)/$(basename -- "$0")" != "$(cd -- "$(dirname -- "${.sh.file}")" && pwd -P)/$(basename -- "${.sh.file}")" ] && sourced=1
elif [ -n "$BASH_VERSION" ]; then
  (return 0 2>/dev/null) && sourced=1 
else # All other shells: examine $0 for known shell binary filenames.
  # Detects `sh` and `dash`; add additional shell filenames as needed.
  case ${0##*/} in sh|-sh|dash|-dash) sourced=1;; esac
fi

if [ $sourced = 0 ]
  then 
    echo ""
    echo "  * * * * * NOTICE * * * * * "
    echo ""
    echo "This script needs to be run 'sourced' so it can export variables into the shell for other scripts to use."
    echo ""
    echo "To run this script sourced, run this script like '. ./init.gcp.sh' with the dot-space before the script."
    echo ""
    echo "Do you want to let the rest of the script run unsourced? It will continue to do project setup, but any environment variables won't be available for other scripts to use. (yes/no)"
    read CONTINUE_UNSOURCED
    if [ $CONTINUE_UNSOURCED != 'yes' ]; then 
      return 
    fi
fi
# =====================================

# =====================================
#         current selections

echo ""
echo "Currently selected gcp auth account and project:"
echo "(this step calls 'gcloud' as your user so may require reauthentication)"
echo ""
echo "Selected auth account:"
echo "==================================="
gcloud auth list
echo ""
echo "Selected project:"
echo "==================================="
gcloud config list project
echo "==================================="
echo "Are these the desired selections? (yes/no)"
read CONFIG_ACCEPTABLE
if [ $CONFIG_ACCEPTABLE != "yes" ]
  then
    echo "To make a change:"
    echo "run 'gcloud config set account [ACCOUNT]' to change the selected account"
    echo "run 'gcloud config set project [project-id]' to change the selected project"
    return
  else
    echo ""
    echo "Great! Initializing shell."
    echo ""
fi
# =====================================

# variables
STARTING_DIR=$(pwd)
TEMP_DIR=$STARTING_DIR/temp

# make temp directory if it doesn't exist
if [ ! -d "$TEMP_DIR" ]; then mkdir $TEMP_DIR; fi

# set project id as env variable
export GCP_PROJECT_ID=`gcloud info --format="value(config.project)"`

echo "Starting project setup (if any needed)..."

# =====================================
#         terraform bucket

# create the terraform bucket if it doesn't already exist
TF_BUCKET_EXISTS=`gsutil ls | grep terraform_state`
if [ -z "$TF_BUCKET_EXISTS" ]; then
  echo ""
  echo "The terraform state storage bucket wasn't found. Creating it now..."
  TF_RANDOM_SUFFIX=`shuf -i 2000-65000 -n 1`
  gsutil mb gs://terraform_state_"$TF_RANDOM_SUFFIX"
fi

# get terraform bucket id and set as env variable
export GCP_TERRAFORM_BUCKET=`gsutil ls | grep terraform_state | sed -e 's#gs://##' -e 's#/##'`
# =====================================

# =====================================
#     terraform service account

# create the terraform service account if it doesn't already exist
NEW_TF_SA='false'
TF_SA_EXISTS=`gcloud iam service-accounts list --format="value(email)" | grep terraform@`
if [ -z "$TF_SA_EXISTS" ]; then
  echo ""
  echo "The terraform service account wasn't found. Creating it now..."
  gcloud iam service-accounts create terraform --display-name="terraform sa"

  # add roles to the new service account
  TERRAFORM_SERVICE_ACCOUNT=`gcloud iam service-accounts list --format="value(email)" --filter=name:"terraform@"`
  gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" --member=serviceAccount:"$TERRAFORM_SERVICE_ACCOUNT" --role='roles/editor'
  gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" --member=serviceAccount:"$TERRAFORM_SERVICE_ACCOUNT" --role='roles/iam.securityAdmin'
  gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" --member=serviceAccount:"$TERRAFORM_SERVICE_ACCOUNT" --role='roles/compute.networkAdmin'
  gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" --member=serviceAccount:"$TERRAFORM_SERVICE_ACCOUNT" --role='roles/secretmanager.secretAccessor'

  NEW_TF_SA='true'
fi

# delete any existing tf key if we just created a new service account
if [ $NEW_TF_SA = 'true' ]; then
  rm -f "$TEMP_DIR/gcp_terraform_key.json"
fi

# download service account credentials if it doesn't exist yet 
# then set into env variable
if [ ! -f "$TEMP_DIR/gcp_terraform_key.json" ]
  then
    echo ""
    echo "The terraform service account key wasn't found. Creating it now..."
    TERRAFORM_SERVICE_ACCOUNT=`gcloud iam service-accounts \
    list --format="value(email)" --filter=name:"terraform@"`

    gcloud iam service-accounts keys create "$TEMP_DIR/gcp_terraform_key.json" \
    --iam-account=$TERRAFORM_SERVICE_ACCOUNT
fi
export GOOGLE_APPLICATION_CREDENTIALS="$TEMP_DIR/gcp_terraform_key.json"
# =====================================

# =====================================
#               apis

echo ""
echo "Enabling apis if needed..."

# turn on the cloud resource manager api so terraform will work
gcloud services enable cloudresourcemanager.googleapis.com

# turn on the app engine api so app engine, firestore, datastore, etc will work
gcloud services enable appengine.googleapis.com

# turn on the other apis we will need so we don't end up trying to use them before they are ready...
# sometimes google enables apis but not really all the way
# and it takes a bit for everything to propagate
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudtrace.googleapis.com
gcloud services enable redis.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable vpcaccess.googleapis.com
# =====================================

# =====================================
#             app engine

AE_DEFAULT_APP_DIR=$STARTING_DIR/../../projects/gcp/app-engine/hello-world

echo ""
echo "Checking for app engine..."
AE_EXISTS=`gcloud app versions list | grep -v 'was not found'`
if [ -z "$AE_EXISTS" ]; then
  echo ""
  echo "App engine wasn't found. This will enable it in us-central."
  echo ""
  gcloud app create --region=us-central

  echo ""
  echo "Deploying the default app engine service (hello world)..."
  cd $AE_DEFAULT_APP_DIR
  gcloud app deploy
  cd $STARTING_DIR
fi
# =====================================

echo ""
echo "Project setup complete."
if [ $sourced != 0 ]; then
  echo ""
  echo "The shell has been loaded and can now be used in setup scripts."
fi
echo ""