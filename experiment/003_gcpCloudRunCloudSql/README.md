# Cloud Run to Cloud Sql Experiment

This goes along with the blog article here: https://blog.caseyharalson.com/posts/gcp-cloud-run-to-cloud-sql

I make no guarantees about the correctness of this code.
Use with your own responsibility.

For a basic overview of the steps, take a look at [the README from the last experiment.](../002_gcpCloudRunScaling/README.md)

## Setup

1. Change to the "experiment/000_init" folder and run the init.gcp.sh script sourced: `. ./init.gcp.sh`
2. Open GCP and create two secrets in Secret Manager:
    - PGUSER-003 = postgres or whatever user
    - PGPASSWORD-003 = postgres or whatever password
3. Run the network setup script: `./network.setup.sh`
4. Run the cloudsql setup script: `./cloudsql.setup.sh`
5. Run the cloudrun setup script: `./cloudrun.setup.sh`
    - Say "yes" when the script asks if you want to build and deploy the latest container source to the cloud run service. We still need to create the database before the service will be ready, but this will allow the db jobs to be run.
6. Navigate to the "temp.cloudrun/scripts" folder and run the cloud-run db creation job: `./cloud-run.job.db-create.sh`
    - This takes a minute or so to complete. So wait for it to complete in the GCP console before moving on.
7. While still in the cloud run scripts folder, run the cloud-run db seed job: `./cloud-run.job.db-seed.sh`
8. 

