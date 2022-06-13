#!/bin/bash

# Currently is supported two different service types: fhir, swagger-pg
# fhir - generates the FHIR related service layout
# swagger-pg - generates a service layout based on swagger with postgres adapter

# example 1: sh scripts/init-service.sh --service myservice --type fhir
# example 2: sh scripts/init-service.sh -s myservice -t fhir

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
      --service | -s)
        SERVICE_NAME="$2"
        shift # past argument
        shift # past value
        ;;
      --type | -t)
        SERVICE_TYPE="$2"
        shift # past argument
        shift # past value
        ;;
  esac
done
set -- "${POSITIONAL[@]}"

if [[ $SERVICE_NAME == "" ]]; then
    echo "empty service name"
    exit 1
fi

if [[ $SERVICE_TYPE != "fhir" && $SERVICE_TYPE != "swagger-pg" ]]; then
    echo "unknown service type"
    exit 1
fi

SERVICE_PATH="./services/$SERVICE_NAME"

# creates service layout folders
function makeLayout() {
    arr=("$@")
    for i in "${arr[@]}"; do
        echo "Create dir $i"
        mkdir "$i"
    done
}

# takes template by given path and creates file
function filesFromTemplate() {
    arr=("$@")
    for i in "${arr[@]}"; do
        #src=$(cat "${i%%::*}")
        src=$(cat "${i%%::*}" | sed "s/{{SERVICE}}/${SERVICE_NAME}/g")
        dst="${i##*::}"
        echo "Create ${dst}"
        echo "${src}" > "${dst}"
    done
}

if [[ $SERVICE_TYPE == "swagger-pg" ]]; then
   TEMPLATE=$(cat configs/templates/go/swagger-service/swagger.yaml.tmpl)
   RESULT_FILE=$(echo "${TEMPLATE}" | sed "s/{{SERVICE}}/${SERVICE_NAME}/g")
   echo "generating swagger.yaml"
   echo "${RESULT_FILE}" > ./api/openapi/"${SERVICE_NAME}".yaml
fi


if [[ $SERVICE_TYPE == "swagger-pg" ]]; then
  SERVICE_LAYOUT=(
      "$SERVICE_PATH"
      "$SERVICE_PATH/adapter"
      "$SERVICE_PATH/adapter/repository"
      "$SERVICE_PATH/adapter/repository/pg"
      "$SERVICE_PATH/cmd"
      "$SERVICE_PATH/controller"
      "$SERVICE_PATH/controller/http"
      "$SERVICE_PATH/entity"
      "$SERVICE_PATH/migration"
      "$SERVICE_PATH/migration/schema"
      "$SERVICE_PATH/usecase"
      "./cmd/${SERVICE_NAME}"
  )

  TEMPLATE_MAP=(
      "configs/templates/go/swagger-service/swagger.yaml.tmpl::./api/openapi/${SERVICE_NAME}.yaml"
      "configs/templates/go/swagger-service/pgservice/repository.go.tmpl::${SERVICE_PATH}/adapter/repository/pg/repository.go"
      "configs/templates/go/swagger-service/pgservice/model.go.tmpl::${SERVICE_PATH}/adapter/repository/pg/model.go"
      "configs/templates/go/swagger-service/pgservice/cmd.go.tmpl::${SERVICE_PATH}/cmd/cmd.go"
      "configs/templates/go/swagger-service/pgservice/config.go.tmpl::${SERVICE_PATH}/cmd/config.go"
      "configs/templates/go/swagger-service/pgservice/migrate.go.tmpl::${SERVICE_PATH}/cmd/migrate.go"
      "configs/templates/go/swagger-service/pgservice/run.go.tmpl::${SERVICE_PATH}/cmd/run.go"
      "configs/templates/go/swagger-service/server.go.tmpl::${SERVICE_PATH}/controller/http/server.go"
      "configs/templates/go/swagger-service/handler.go.tmpl::${SERVICE_PATH}/controller/http/handler.go"
      "configs/templates/go/swagger-service/entity.go.tmpl::${SERVICE_PATH}/entity/entity.go"
      "configs/templates/go/swagger-service/pgservice/migration.up.sql.tmpl::${SERVICE_PATH}/migration/schema/1_init.up.sql"
      "configs/templates/go/swagger-service/pgservice/migration.down.sql.tmpl::${SERVICE_PATH}/migration/schema/1_init.down.sql"
      "configs/templates/go/swagger-service/usecase.go.tmpl::${SERVICE_PATH}/usecase/usecase.go"
      "configs/templates/go/swagger-service/pgservice/readme.md.tmpl::${SERVICE_PATH}/README.md"
      "configs/templates/go/swagger-service/pgservice/.env.dev.tmpl::${SERVICE_PATH}/.env.dev"
      "configs/templates/go/semver.yaml.tmpl::${SERVICE_PATH}/.semver.yaml"
      "configs/templates/go/main.go.tmpl::./cmd/${SERVICE_NAME}/main.go"
  )
elif [[ $SERVICE_TYPE == "fhir" ]]; then
  SERVICE_LAYOUT=(
        "$SERVICE_PATH"
        "$SERVICE_PATH/adapter"
        "$SERVICE_PATH/adapter/fhir"
        "$SERVICE_PATH/cmd"
        "$SERVICE_PATH/controller"
        "$SERVICE_PATH/controller/http"
        "$SERVICE_PATH/entity"
        "$SERVICE_PATH/usecase"
        "./cmd/${SERVICE_NAME}"
    )

    TEMPLATE_MAP=(
        "configs/templates/go/fhir-service/fhir.go.tmpl::${SERVICE_PATH}/adapter/fhir/fhir.go"
        "configs/templates/go/fhir-service/cmd.go.tmpl::${SERVICE_PATH}/cmd/cmd.go"
        "configs/templates/go/fhir-service/config.go.tmpl::${SERVICE_PATH}/cmd/config.go"
        "configs/templates/go/fhir-service/run.go.tmpl::${SERVICE_PATH}/cmd/run.go"
        "configs/templates/go/fhir-service/handler.go.tmpl::${SERVICE_PATH}/controller/http/handler.go"
        "configs/templates/go/fhir-service/server.go.tmpl::${SERVICE_PATH}/controller/http/server.go"
        "configs/templates/go/fhir-service/entity.go.tmpl::${SERVICE_PATH}/entity/entity.go"
        "configs/templates/go/fhir-service/usecase.go.tmpl::${SERVICE_PATH}/usecase/usecase.go"
        "configs/templates/go/fhir-service/readme.md.tmpl::${SERVICE_PATH}/README.md"
        "configs/templates/go/fhir-service/.env.dev.tmpl::${SERVICE_PATH}/.env.dev"
        "configs/templates/go/semver.yaml.tmpl::${SERVICE_PATH}/.semver.yaml"
        "configs/templates/go/main.go.tmpl::./cmd/${SERVICE_NAME}/main.go"
    )
fi

makeLayout "${SERVICE_LAYOUT[@]}"
filesFromTemplate "${TEMPLATE_MAP[@]}"

if [[ $SERVICE_TYPE == "swagger-pg" ]]; then
    echo "generating code from swagger"
    echo $(sh ./scripts/gen-openapi.sh -p ${SERVICE_NAME})
fi

if [[ $SERVICE_TYPE == "swagger-pg" ]]; then
    echo "generating migration bindata"
      echo $(go-bindata -o ${SERVICE_PATH}/migration/schema/bindata.go \
      	-prefix ${SERVICE_PATH}/migration/schema \
      	-pkg schema ${SERVICE_PATH}/migration/schema/...)
fi

echo "Generating workflows"
echo $(sh scripts/workflows.sh)