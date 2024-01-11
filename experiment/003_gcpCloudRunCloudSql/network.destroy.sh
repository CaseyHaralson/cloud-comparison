#!/bin/sh

# verify pre-destroy has been completed
echo ""
echo "Before the network can be destroyed, some other terraform items might have been created and will need to be deleted first."
echo ""
echo "Have all other services that use the network been destroyed? (yes/no)"
read OTHER_SERVICES_DELETED
if [ $OTHER_SERVICES_DELETED != 'yes' ]; then return; fi

# include variables
FILENAME=$(basename "$0")
FILENAME_SUFFIX='.destroy.sh'
FILENAME_PREFIX=`echo $FILENAME | sed 's#'"${FILENAME_SUFFIX}"'##'`
. ./${FILENAME_PREFIX}.variables.sh # sourced

# check to make sure init was run
cd $INIT_DIR
export VERIFY_SCRIPT_ARGUMENTS="gcp"
. ./verify.sh # sourced
if [ $VERIFY_SCRIPT_RETURN = false ]; then return 1; fi

# run terraform destroy
cd $TEMP_DIR
terraform destroy ${TERRAFORM_VARIABLES}
