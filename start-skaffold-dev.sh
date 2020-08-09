#!/bin/bash

# Pre-Flight check if '$TAG' variable is set
if [[ -z ${TAG} ]]
then 
  echo '$TAG variable is NOT set! Be sure to export $TAG variable before Skaffold deployment.'
  echo 'Example: $ export TAG="x.y.z"'
  echo
  exit 1
fi


# Runs Skaffold in Dev Mode
skaffold dev -t "${TAG}"