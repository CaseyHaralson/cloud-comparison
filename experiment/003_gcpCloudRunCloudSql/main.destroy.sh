#!/bin/sh

# include variables
. ./main.variables.sh

# run terraform destroy
cd $TEMP_DIR
terraform destroy ${TERRAFORM_VARIABLES}
