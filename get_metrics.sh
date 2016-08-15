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

# Get metric values
printf "\nMetric Name: "
read metric_name
printf "First Day(YYYYMMDD): "
read first_day
first_day=`date -j -f %Y%m%d ${first_day} +%s`
printf "Last Day(YYYYMMDD): "
read last_day
last_day=`date -j -f %Y%m%d ${last_day} +%s`

# メソッドで呼び出すと、なぜか400 bad requestになり値が取れない
# metric_url="https://mackerel.io/api/v0/hosts/${host_id}/metrics\?name\=${metric_name}\&from\=${first_day}\&to\=${last_day}"
# metric_values=`get_json ${api_key} ${metric_url}`
metric_values=`curl -s -X GET -H "X-Api-Key: ${api_key}" https://mackerel.io/api/v0/hosts/${host_id}/metrics\?name\=${metric_name}\&from\=${first_day}\&to\=${last_day}`
sum=`echo ${metric_values} | jq '.metrics | map(.value) | add'`
count=`echo ${metric_values} | jq '.metrics | length'`
max=`echo ${metric_values} | jq '.metrics | map(.value) | max'`
average=`echo ${metric_values} | jq '.metrics | map(.value) | length as $metric_length | add / $metric_length'`

cat << EOS

Results:
  Metric Name: ${metric_name}
  Sum: ${sum}
  Count: ${count}
  Average: ${average}
  Max: ${max}
EOS
