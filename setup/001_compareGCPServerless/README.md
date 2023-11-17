# Compare GCP Serverless Web Services

This goes along with the blog article here: https://blog.caseyharalson.com/posts/post

## Project Setup Steps

Note: because of how many permissions are needed to create and run some of these services, it is probably easiest to follow these steps from your personal cloud vs a company cloud.

1. Have access to GCP with billing and whatnot turned on.
2. Create a new GCP project where all of this work can be contained.
3. Create a storage bucket that contains the name "terraform_state" in the name. This will be used to hold all of the terraform state information.
4. Create a service account called "terraform" with the following roles: "editor", "iam.securityAdmin", "compute.networkAdmin", "secretmanager.secretAccessor"
5. Enable the following apis: "cloudresourcemanager".
6. If your company has a domain restricted sharing policy, you will need to turn that off for this project. Turn off (turning off means "allow all") both "Domain restricted contacts" and "Domain restricted sharing".
7. 

## Service Setup Steps

These steps assume you have already cloned this project into a linux machine and have the gcloud cli, terraform cli, etc installed.
If you are on Windows and want to setup WSL, the following project can be used to setup a linux vm in Windows with all the prerequisites: https://github.com/CaseyHaralson/wsl-setup

1. In the linux console, navigate to the "setup/000_init" folder and run the gcp init script sourced so the setup will load the shell with environment variables: `. ./init.gcp.sh`
    - If you need to authorize with the gcloud cli before running the script: `gcloud auth login`
    - Check the script output to make sure the correct auth account and project are selected. You will be given a chance to change the account and project if needed.
2. Use the same shell to navigate to the "setup/001_compareCGPServerless" folder and run the services setup script: `./services.setup.sh`
    - This will give you a chance to review the Terraform plan before applying. Say "yes" if you approve.
    - If Terraform throws errors due to apis not being enabled, wait a few minutes and run the script again. The needed apis will be enabled in the Terraform plan, but Google Cloud (or Terraform) has issues.
    - The script will also ask if you want to build and deploy the latest container source to the cloud run service. Say "yes". There isn't a way to deploy code directly to cloud run with Terraform so the script will build and deploy to code as a separate step.

## Cleanup Steps

1. Using a shell that has been initialized as described in the setup steps, navigate to the particular setup folder and run the services cleanup script: `./services.destroy.sh`
2. 