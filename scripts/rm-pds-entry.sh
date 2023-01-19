#!/usr/bin/env bash
set -u
set -o pipefail

echo $2
deploy_id=`curl -X 'GET' \
  "https://prod.pds.portworx.com/api/tenants/$2/deployment-targets?cluster_id=$3" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $1"`
did=`echo "$deploy_id" | jq '.[][0].id' | head -1`


rm_id=`curl -X 'DELETE' \
  "https://prod.pds.portworx.com/api/deployment-targets/$did" \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $1"`

echo $rm_id | jq '.http_status'
