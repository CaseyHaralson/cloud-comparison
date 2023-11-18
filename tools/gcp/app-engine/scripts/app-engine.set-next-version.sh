#!/bin/sh

echo ""
echo "app-engine.set-next-version script: find and set the next version of the app engine service (defaults to v1 if this is the first version)..."
echo "(this step calls 'gcloud' as your user so may require reauthentication)"
echo ""

NEXT_APPENGINE_VERSION="1"

# get the current app engine name from the terraform output
APPENGINE_APP_NAME=`terraform -chdir=../ output | grep app_engine_app_name | sed -e 's#app_engine_app_name##' -e 's#=##' | xargs`

# if we got an app engine name that means that terraform has been run
# so find the current version
if [ ! -z $APPENGINE_APP_NAME ]
  then
    # check the number of versions for this app service
    # this needs to run BEFORE terraform, so can't use terraform output to get the name of the app
    CURRENT_VERSION=`gcloud app versions list --service="$APPENGINE_APP_NAME" --format=json | jq '.[0].id' | sed -e 's#"##g' -e 's#v##g' | xargs`

    NEXT_APPENGINE_VERSION=$((1+${CURRENT_VERSION:=0}))
fi

# set the version
sed -i -e 's#_NEXT_VERSION_#v'$NEXT_APPENGINE_VERSION'#g' ../app-engine.variables.tf