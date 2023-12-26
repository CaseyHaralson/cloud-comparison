#!/bin/sh

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
