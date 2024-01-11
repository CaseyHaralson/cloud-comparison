#!/bin/sh

P_INDEX=003
P_SUFFIX='infra'
PIPELINE="${P_INDEX}.${P_SUFFIX}"_gcpCloudRunCloudSql
STARTING_DIR=$(pwd)
TEMP_DIR=$STARTING_DIR/temp."$P_SUFFIX"
TOOL_SCRIPTS=$TEMP_DIR/scripts
INIT_DIR=$STARTING_DIR/../000_init
TERRAFORM_VARIABLES_DIR=$STARTING_DIR/tfvars
TERRAFORM_VARIABLES_FILE=${P_SUFFIX}.tfvars

TERRAFORM_BASE_DIR=$STARTING_DIR/../../tools/gcp/base
TERRAFORM_NETWORK_DIR=$STARTING_DIR/../../tools/gcp/network
TERRAFORM_CLOUDSQL_DIR=$STARTING_DIR/../../tools/gcp/cloud-sql

# set the state prefix so these changes don't overlap with anything else
TERRAFORM_STATE_PREFIX="terraform/state/$PIPELINE"

TERRAFORM_BASE_VARIABLES='-var=project_id='"$GCP_PROJECT_ID"' 
                          -var=terraform_state_bucket='"$GCP_TERRAFORM_BUCKET"'
                          -var=project_resource_naming_suffix=-'"$P_INDEX"
TERRAFORM_VARIABLES="-var-file=$TERRAFORM_VARIABLES_FILE ${TERRAFORM_BASE_VARIABLES}"