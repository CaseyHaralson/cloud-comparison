#!/bin/sh

# include variables
FILENAME=$(basename "$0")
FILENAME_SUFFIX='.destroy.sh'
FILENAME_PREFIX=`echo $FILENAME | sed 's#'"${FILENAME_SUFFIX}"'##'`
. ./${FILENAME_PREFIX}.variables.sh # sourced

# run terraform destroy
cd $TEMP_DIR
terraform destroy ${TERRAFORM_VARIABLES}
