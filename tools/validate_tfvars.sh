#! /bin/bash

PROJECT_ID=$1
REGION=$2
ZONES=$3

if [ -z "$PROJECT_ID" ]; then
    echo "Error: 'PROJECT_ID' is required"
    exit 1
elif [ -z "$REGION" ] || [ "${REGION}" = "global" ]; then
    echo "Error: 'REGION' is required, and it cannot be set to 'global'"
    exit 1
elif [ -z "$ZONES" ]; then
    echo "Error: 'ZONES' is required"
    exit 1
elif [ -n "$ZONES" ]; then
    IFS=" "
    read -ra ZONE_ARRAY <<< "$ZONES"
    for zone in "${ZONE_ARRAY[@]}"; do
        if [[ $zone != $REGION* ]]; then
            echo "Error: 'ZONES' should depend on chosen 'REGION'"
            exit 1
        fi
    done
fi