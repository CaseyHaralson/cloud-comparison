#!/bin/sh

# fail if any called scripts fail
set -e

echo ""
echo "Do you want to build and deploy the latest container source to the cloud run service? (yes/no)"
read ACTION
if [ $ACTION = 'yes' ]; then

  # build the container image
  ./cloud-run.build-image.sh

  # deploy the container image
  ./cloud-run.service.deploy.sh

fi