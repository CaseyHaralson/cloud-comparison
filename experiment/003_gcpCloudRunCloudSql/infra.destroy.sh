#!/bin/sh

# verify pre-destroy has been completed
echo ""
echo "Before the infrastructure can be destroyed, some non-terraform items might have been created and will need to be deleted first."
echo ""
echo "Have all user databases been deleted? (yes/no)"
read DATABASES_DELETED
if [ $DATABASES_DELETED != 'yes' ]; then return; fi

# include variables
. ./infra.variables.sh

# run terraform destroy
cd $TEMP_DIR
terraform destroy ${TERRAFORM_VARIABLES}
