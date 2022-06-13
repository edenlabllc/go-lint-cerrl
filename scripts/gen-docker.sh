#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -s serviceName -t template"
   echo -e "\t-s Description of what is serviceName"
   echo -e "\t-t Description of what is used docker template"
   exit 1 # Exit script after printing help
}

while getopts "s:t:" opt
do
   case "$opt" in
      s ) serviceName="$OPTARG" ;;
      t ) template="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$serviceName" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

echo "Set service: $serviceName"

docker --version

# read the workflow template
DOCKER_TEMPLATE=$(cat configs/templates/dockerfile.tmpl)

# Main build function. Takes a directory as input.
genDocker () {
  echo "Build input = $1"
  echo "generating docker for services/$1"

  # replace template route placeholder with route name
  if [ "$2" != "-" ]
  then
    DOCKER_CUSTOM_TEMPLATE=$(cat "$2")
    DOCKER=$(echo "${DOCKER_CUSTOM_TEMPLATE}" | sed "s/{{COMMAND}}/$1/g")
  else
    DOCKER=$(echo "${DOCKER_TEMPLATE}" | sed "s/{{COMMAND}}/$1/g")
  fi

  # save workflow to dockerfile.{COMMAND}
  echo "${DOCKER}" > dockerfile.$1
}

echo "Process ${serviceName}"
genDocker $serviceName $template
