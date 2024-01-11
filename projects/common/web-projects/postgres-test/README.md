# postgres-test

## Config Secrets

Select which cloud to get the secrets from by filling the POSTGRES_CONFIG_SECRET_SOURCE environment variable or use the default development values. Secret Source Options: gcp

### GCP Secrets

The following environment variables need to be set to pull the correct secrets from the secret manager:
- GCP_SECRETKEY_POSTGRES_HOST
- GCP_SECRETKEY_POSTGRES_PORT
- 

## Database Commands

### Create Database

Locally:

`npm run db:create`

### Generate Migration

Locally:

`npm run db:migration:generate --name=[migration-name]`

### Run Migrations

Locally:

Running the app should update the schema to your codebase's current schema.

Non-Local:

`npm run db:migration:run`

### Seed Data

`npm run db:seed`

