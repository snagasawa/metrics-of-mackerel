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
