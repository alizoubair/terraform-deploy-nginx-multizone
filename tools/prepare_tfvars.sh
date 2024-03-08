#! /bin/bash

REGION=$1
ZONES=$2

IFS=" "
read -ra ZONE_ARRAY <<< "$ZONES"
printf -v ZONES_VALUE '"%s",' "${ZONE_ARRAY[@]}"
ZONES_VALUE="[${ZONES_VALUE%,}]"

cat << EOF > ../infra/terraform.tfvars
availability_type = "REGIONAL"
firewall_source_ranges = [
  // Health check service ip
  "130.211.0.0/22",
  "35.191.0.0/16",
]
region = "$REGION"
zones  = $ZONES_VALUE
EOF