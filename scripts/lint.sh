#!/usr/bin/env bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -u self"
   echo -e "\t-u Run scripts values [docker|local]"
   exit 1 # Exit script after printing help
}

while getopts "u:" opt
do
   case "$opt" in
      u ) used="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$used" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

echo "Used in: $used"

CheckDocker="docker"
if [ "$used" = "$CheckDocker" ]
then
  cd /app/
fi

go version -m $(which golangci-lint)

golangci-lint run -v --config ./.golangci.yml --timeout=10m
