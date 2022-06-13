#!/bin/bash

# read the workflow template
WORKFLOW_TEMPLATE=$(cat .github/workflow-template.yaml)
PWD=$(PWD)

# iterate each route in routes directory
for SERVICE in $(ls $PWD/services); do
    echo "generating workflow for services/${SERVICE}"

    # replace template route placeholder with route name
    WORKFLOW=$(echo "${WORKFLOW_TEMPLATE}" | sed "s/{{SERVICE}}/${SERVICE}/g")

    # save workflow to .github/workflows/{SERVICE}
    echo "${WORKFLOW}" > .github/workflows/${SERVICE}.yaml
done