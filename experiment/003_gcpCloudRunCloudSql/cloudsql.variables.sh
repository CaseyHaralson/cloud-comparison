#!/bin/sh

P_INDEX=003
P_SUFFIX='cloudsql'
PIPELINE="${P_INDEX}.${P_SUFFIX}"_gcpCloudRunCloudSql
STARTING_DIR=$(pwd)
PROJECT_ROOT_DIR=$STARTING_DIR/../..
TEMP_DIR=$STARTING_DIR/temp."$P_SUFFIX"
TOOL_SCRIPTS=$TEMP_DIR/scripts
INIT_DIR=$PROJECT_ROOT_DIR/experiment/000_init
TERRAFORM_VARIABLES_DIR=$STARTING_DIR/tfvars
TERRAFORM_VARIABLES_FILE=${P_SUFFIX}.tfvars

TERRAFORM_BASE_DIR=$PROJECT_ROOT_DIR/tools/gcp/base
TERRAFORM_CLOUDSQL_DIR=$PROJECT_ROOT_DIR/tools/gcp/cloud-sql

# set the state prefix so these changes don't overlap with anything else
TERRAFORM_STATE_PREFIX="terraform/state/$PIPELINE"

# remote state prefixes
TERRAFORM_NETWORK_STATE_PREFIX=`echo ${TERRAFORM_STATE_PREFIX} | sed 's#'"${P_INDEX}.${P_SUFFIX}"'#'"${P_INDEX}"'.network#g'`

TERRAFORM_BASE_VARIABLES='-var=project_id='"$GCP_PROJECT_ID"' 
                          -var=terraform_state_bucket='"$GCP_TERRAFORM_BUCKET"'
                          -var=project_resource_naming_suffix=-'"$P_INDEX"'
                          -var=network_remotestate_prefix='"$TERRAFORM_NETWORK_STATE_PREFIX"
TERRAFORM_VARIABLES="-var-file=$TERRAFORM_VARIABLES_FILE ${TERRAFORM_BASE_VARIABLES}"