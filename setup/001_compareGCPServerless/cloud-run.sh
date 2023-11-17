#!/bin/sh

# =====================================
#             cloud run

echo ""
echo "Cloud run step..."

# run function zip
# copy to temp dir
cd $CONTAINER_DIR
npm run zip
cp container-source.zip $TEMP_DIR

# copy terraform scripts to temp dir
cd $TERRAFORM_CLOUDRUN_DIR
cp -r ./* $TEMP_DIR
# =====================================
