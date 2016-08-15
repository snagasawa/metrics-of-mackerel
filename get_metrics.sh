#! /bin/bash
get_json() {
  curl -s -X GET -H "X-Api-Key: $1" $2
}

# Get a organization name
printf 'Api Key: '
read api_key
organization_url='https://mackerel.io/api/v0/org'
organization=`get_json ${api_key} ${organization_url}`
printf 'Organization Name: '
echo ${organization} | jq -r .name

# Get hosts
hosts_url='https://mackerel.io/api/v0/hosts'
hosts=`get_json ${api_key} ${hosts_url}`
echo "\nHosts: "
echo ${hosts} | jq -r '.hosts[] | .name'

# Get metric names
printf "\nHost Name: "
read host_name
echo ${host_name}
host_id=`echo ${hosts} | jq -r --arg host_name ${host_name} '.hosts[] | if .name == $host_name then .id else empty end'`
metric_names_url="https://mackerel.io/api/v0/hosts/${host_id}/metric-names"
metrics=`get_json ${api_key} ${metric_names_url}`
echo "\nMetrics: "
echo ${metrics} | jq -r '.names[]'
