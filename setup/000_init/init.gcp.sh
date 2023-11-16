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
    echo "  * * * * * WARNING * * * * * "
    echo ""
    echo "This script needs to be run 'sourced' so it can export variables into the shell for other scripts to use."
    echo ""
    echo "Run this script like '. ./init.gcp.sh' with the dot-space before the script."
    echo ""
    echo "The rest of the script output will be for debugging purposes only."
    echo "(press enter)"
    read DUMMY_INPUT
    echo ""
    echo ""
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

# get terraform bucket id and set as env variable
export GCP_TERRAFORM_BUCKET=`gsutil ls | grep terraform_state | sed -e 's#gs://##' -e 's#/##'`

# download service account credentials if it doesn't exist yet 
# then set into env variable
if [ ! -f "$TEMP_DIR/gcp_terraform_key.json" ]
  then
    TERRAFORM_SERVICE_ACCOUNT=`gcloud iam service-accounts \
    list --format="value(email)" --filter=name:"terraform@"`

    gcloud iam service-accounts keys create "$TEMP_DIR/gcp_terraform_key.json" \
    --iam-account=$TERRAFORM_SERVICE_ACCOUNT
fi
export GOOGLE_APPLICATION_CREDENTIALS="$TEMP_DIR/gcp_terraform_key.json"
