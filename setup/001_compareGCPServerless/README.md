# Compare GCP Serverless Web Services

This goes along with the blog article here: https://blog.caseyharalson.com/posts/post

## Project Setup Steps

Note: because of how many permissions are needed to create and run some of these services, it is probably easiest to follow these steps from your personal cloud vs a company cloud.
For example, to turn on App Engine (or by effect Firestore, Datastore, etc) you will need project owner permissions.

1. Have access to GCP with billing and whatnot turned on.
2. Create a new GCP project where all of this work can be contained.

## Service Setup Steps

These steps assume you have already cloned this project into a linux machine and have the gcloud cli, terraform cli, etc installed.
If you are on Windows and want to setup WSL, the following project can be used to setup a linux vm in Windows with all the prerequisites: https://github.com/CaseyHaralson/wsl-setup

1. In the linux console, navigate to the "setup/000_init" folder and run the gcp init script sourced so the setup will load the shell with environment variables: `. ./init.gcp.sh`
    - If you need to authorize with the gcloud cli before running the script: `gcloud auth login`
    - Check the script output to make sure the correct auth account and project are selected. You will be given a chance to change the account and project if needed.
    - This script will setup the project if needed too: 
        - create the terraform service account
        - create a storage bucket for terraform state
        - turn on initial apis
        - create an app engine instance and deploy a default app
2. Use the same shell to navigate to the "setup/001_compareCGPServerless" folder and run the services setup script: `./services.setup.sh`
    - This will give you a chance to review the Terraform plan before applying. Say "yes" if you approve.
    - The script will also ask if you want to build and deploy the latest container source to the cloud run service. Say "yes". There isn't a way to deploy code directly to cloud run with Terraform so the script will build and deploy to code as a separate step.

## Cleanup Steps

There are two ways to cleanup:

1. Delete the project. This removes all resources and setting changes.
2. Using a shell that has been initialized as described in the setup steps, navigate to this particular setup folder and run the destroy script: `./services.destroy.sh`
    - Note: this still keeps some resources around, but that can be useful if you want to keep playing around without having to create the project again.
