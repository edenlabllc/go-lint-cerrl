#!/usr/bin/env bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p projectName"
   echo -e "\t-p Description of what is projectName"
   exit 1 # Exit script after printing help
}

while getopts "p:" opt
do
   case "$opt" in
      p ) projectName="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$projectName" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

echo "Set params: $projectName"

ROOT_PATH="./services/$projectName"
RESTAPI_PATH="$ROOT_PATH/controller/http/generated"
if [ ! -d "$ROOT_PATH" ]; then
    echo "Can not find directory: "$ROOT_PATH""
    exit 1
fi

if [[ ! -d "$RESTAPI_PATH" ]]; then
    echo "[oapi-codegen] mkdir \"generated\" for service $projectName: $RESTAPI_PATH"
    mkdir "$RESTAPI_PATH"
fi

#REST_CLIENT_PATH="./pkg/apiclient/$projectName"
#if [[ ! -d "$REST_CLIENT_PATH" ]]; then
#    echo "[oapi-codegen] mkdir \"$projectName\" for client: $REST_CLIENT_PATH"
#    mkdir "$REST_CLIENT_PATH"
#fi

echo "[oapi-codegen] generated models."
oapi-codegen --package generated \
   -templates configs/templates/swagger \
   -generate types -o ./services/$projectName/controller/http/generated/schemas.go \
   ./api/openapi/$projectName.yaml
#oapi-codegen --package generated \
#   -templates configs/templates/swagger \
#   -generate types -o ./pkg/apiclient/$projectName/schemas.go \
#   ./api/openapi/$projectName.yaml

echo "[oapi-codegen] generated spec."
oapi-codegen --package generated \
   -templates configs/templates/swagger \
   -generate spec -o ./services/$projectName/controller/http/generated/spec.go \
   ./api/openapi/$projectName.yaml

echo "[oapi-codegen] generated server."
oapi-codegen --package generated \
   -templates configs/templates/swagger \
   -import-mapping=fiber:github.com/gofiber/fiber/v2,cerror:wasfaty.api/pkg/cerror \
   -generate server \
   -o ./services/$projectName/controller/http/generated/server.go \
   ./api/openapi/$projectName.yaml

#echo "[oapi-codegen] generated clients."
#oapi-codegen --package generated \
#   -templates configs/templates/swagger \
#   -generate client -o ./pkg/apiclient/$projectName/clients.go \
#   ./api/openapi/$projectName.yaml