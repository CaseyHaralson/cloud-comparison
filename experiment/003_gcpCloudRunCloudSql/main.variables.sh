#!/bin/sh

P_INDEX=003
P_SUFFIX='main'
PIPELINE="${P_INDEX}.${P_SUFFIX}"_gcpCloudRunCloudSql
STARTING_DIR=$(pwd)
TEMP_DIR=$STARTING_DIR/temp."$P_SUFFIX"
TOOL_SCRIPTS=$TEMP_DIR/scripts
INIT_DIR=$STARTING_DIR/../000_init
TERRAFORM_VARIABLES_DIR=$STARTING_DIR/tfvars
TERRAFORM_VARIABLES_FILE=${P_SUFFIX}.tfvars

CONTAINER_DIR=$STARTING_DIR/../../projects/common/web-projects/postgres-test
# CONTAINER_DIR=$STARTING_DIR/../../projects/common/web-projects/hello-world

TERRAFORM_BASE_DIR=$STARTING_DIR/../../tools/gcp/base
TERRAFORM_CLOUDRUN_DIR=$STARTING_DIR/../../tools/gcp/cloud-run

# set the state prefix so these changes don't overlap with anything else
TERRAFORM_STATE_PREFIX="terraform/state/$PIPELINE"
# calculate the infra state prefix so we can get values from that state
TERRAFORM_INFRA_STATE_PREFIX=`echo ${TERRAFORM_STATE_PREFIX} | sed 's#'"${P_INDEX}.${P_SUFFIX}"'#'"${P_INDEX}"'.infra#g'`

TERRAFORM_BASE_VARIABLES='-var=project_id='"$GCP_PROJECT_ID"' 
                          -var=terraform_state_bucket='"$GCP_TERRAFORM_BUCKET"'
                          -var=project_resource_naming_suffix=-'"$P_INDEX"
TERRAFORM_CLOUDRUN_VARIABLES='-var=cloudrun_infra_remote_state_prefix='"$TERRAFORM_INFRA_STATE_PREFIX"
TERRAFORM_VARIABLES="-var-file=$TERRAFORM_VARIABLES_FILE ${TERRAFORM_BASE_VARIABLES} ${TERRAFORM_CLOUDRUN_VARIABLES}"