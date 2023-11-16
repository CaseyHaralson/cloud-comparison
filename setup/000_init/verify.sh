#!/bin/sh

CLOUD_PLATFORM=""
VALID=true

# check that an argument was passed to the script like:
# ./verify.sh gcp
# or that there is a VERIFY_SCRIPT_ARGUMENTS variable set
if [ $# -eq 0 -a -z "$VERIFY_SCRIPT_ARGUMENTS" ]
  then
    echo "init verify script: no arguments supplied..."
    echo "Pass in the type of cloud platform to verify (options: gcp)"
    VALID=false
  else
    # set the cloud platform variable
    if [ $# -eq 1 ]
      then
        CLOUD_PLATFORM="$1"
      else
        CLOUD_PLATFORM="$VERIFY_SCRIPT_ARGUMENTS"
    fi
fi

# gcp check
# verify something from the init.gcp script was exported
# which would mean that the script has been run in the shell
if [ "$CLOUD_PLATFORM" = "gcp" ]
  then
    # check the app credentials variable
    if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]
      then 
        echo ""
        echo "The init.gcp script hasn't been run in this shell yet..."
        echo ""
        echo "In this terminal, navigate to the 000_init pipeline and run the init.gcp.sh script."
        echo ""
        echo "Run the script like '. ./init.gcp.sh' with the dot-space at the beginning so the variables are exported into this shell."
        VALID=false
    fi
fi

# set a return value to true/false so a calling script can see
if [ $VALID = true ]
  then
    # echo "\n init verify: everything looks valid \n"
    export VERIFY_SCRIPT_RETURN=true
  else
    # echo "\n init verify: something looks invalid \n"
    export VERIFY_SCRIPT_RETURN=false
fi