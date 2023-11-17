#!/bin/sh

P_INDEX=001
P_SUFFIX='services'
PIPELINE="${P_INDEX}.${P_SUFFIX}"_compareGCPServerless
STARTING_DIR=$(pwd)
PROJECT_ROOT_DIR=$STARTING_DIR/../..
TEMP_DIR=$STARTING_DIR/temp."$P_SUFFIX"
TOOL_SCRIPTS=$TEMP_DIR/scripts
INIT_DIR=$PROJECT_ROOT_DIR/setup/000_init
TERRAFORM_VARIABLES_DIR=$STARTING_DIR/tfvars
TERRAFORM_VARIABLES_FILE=${P_SUFFIX}.tfvars

CONTAINER_DIR=$PROJECT_ROOT_DIR/projects/common/web-projects/hello-world
FUNCTION_DIR=$PROJECT_ROOT_DIR/projects/gcp/functions/hello-world

TERRAFORM_BASE_DIR=$PROJECT_ROOT_DIR/tools/gcp/base
TERRAFORM_CLOUDRUN_DIR=$PROJECT_ROOT_DIR/tools/gcp/cloud-run
TERRAFORM_FUNCTIONS_DIR=$PROJECT_ROOT_DIR/tools/gcp/cloud-functions

# set the state prefix so these changes don't overlap with anything else
TERRAFORM_STATE_PREFIX="terraform/state/$PIPELINE"

TERRAFORM_BASE_VARIABLES='-var=project_id='"$GCP_PROJECT_ID"' 
                          -var=terraform_state_bucket='"$GCP_TERRAFORM_BUCKET"'
                          -var=project_resource_naming_suffix=-'"$P_INDEX"
TERRAFORM_VARIABLES="-var-file=$TERRAFORM_VARIABLES_FILE ${TERRAFORM_BASE_VARIABLES}"
