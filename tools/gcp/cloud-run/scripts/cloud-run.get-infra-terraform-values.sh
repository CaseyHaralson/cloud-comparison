#!/bin/sh

# echo "getting values from terraform..."

if [ -z "$GCP_VPC_SERVERLESS_CONNECTOR" ]; then
  TEMP_SCRIPTS_CWD=$(pwd)
  TEMP_NETWORK_DIR=$TEMP_SCRIPTS_CWD/../../temp.network
  TEMP_CLOUDSQL_DIR=$TEMP_SCRIPTS_CWD/../../temp.cloudsql
  if [ -d "$TEMP_NETWORK_DIR" ] && [ -d "$TEMP_CLOUDSQL_DIR" ]; then
    
    GCP_VPC_SERVERLESS_CONNECTOR=`terraform -chdir="$TEMP_NETWORK_DIR" output --json vpc_serverless_connector_ids | jq '.[0]' | xargs`

    GCP_CLOUDSQL_SERVER_IP=`terraform -chdir="$TEMP_CLOUDSQL_DIR" output --raw cloudsql_server_ip`

    GCP_CLOUDSQL_USER_SECRET_NAME=`terraform -chdir="$TEMP_CLOUDSQL_DIR" output --raw cloudsql_user_secret_name`

    GCP_CLOUDSQL_PASSWORD_SECRET_NAME=`terraform -chdir="$TEMP_CLOUDSQL_DIR" output --raw cloudsql_password_secret_name`

    GCP_CLOUDSQL_SERVER_CA_CERT_SECRET_NAME=`terraform -chdir="$TEMP_CLOUDSQL_DIR" output --raw cloudsql_server_ca_cert_secret_name`

    GCP_CLOUDSQL_CLIENT_CERT_KEY_SECRET_NAME=`terraform -chdir="$TEMP_CLOUDSQL_DIR" output --raw cloudsql_client_cert_key_secret_name`

    GCP_CLOUDSQL_CLIENT_CERT_SECRET_NAME=`terraform -chdir="$TEMP_CLOUDSQL_DIR" output --raw cloudsql_client_cert_secret_name`

  else
    echo ""
    echo "The network and cloudsql terraform pipelines need to be run before this script..."
    echo ""
    exit 1
  fi
fi

# echo "VPC serverless connector: $GCP_VPC_SERVERLESS_CONNECTOR"
# echo "CloudSql server ip: $GCP_CLOUDSQL_SERVER_IP"
# echo "CloudSql user secret name: $GCP_CLOUDSQL_USER_SECRET_NAME"
# echo "CloudSql password secret name: $GCP_CLOUDSQL_PASSWORD_SECRET_NAME"
# echo "CloudSql server ca cert secret name: $GCP_CLOUDSQL_SERVER_CA_CERT_SECRET_NAME"
# echo "CloudSql client cert key secret name: $GCP_CLOUDSQL_CLIENT_CERT_KEY_SECRET_NAME"
# echo "CloudSql client cert secret name: $GCP_CLOUDSQL_CLIENT_CERT_SECRET_NAME"
