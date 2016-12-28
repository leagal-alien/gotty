#! /bin/bash

#古いファイルを退避
if [ -e service_usage_events.csv ]; then
  mv service_usage_events.csv service_usage_events.csv.old
fi

# 最初
cf curl '/v2/service_usage_events?order-direction=asc&page=1&results-per-page=50' > tmp_service_usage.json

next_url="`cat tmp_service_usage.json | jq -c '.next_url'`"

echo "$next_url"



cat tmp_service_usage.json | jq -c '.resources[] |[.metadata.created_at, .entity.service_instance_name, .entity.space_name, .entity.state, .entity.service_instance_type, .entity.service_plan_name]' > service_usage_events.csv.wk


if [ "$next_url" != "null" ]; then
  # 残り 500はリミッター※　仕様が変わったとかで無限に陥らないため

  i=0
  while [ $i -ne 500 ]; do

    command="cf curl ${next_url} > tmp_service_usage.json"
    eval ${command}

    next_url="`cat tmp_service_usage.json | jq -c '.next_url'`"

    cat tmp_service_usage.json | jq -c '.resources[] |[.metadata.created_at, .entity.service_instance_name, .entity.space_name, .entity.state, .entity.service_instance_type, .entity.service_plan_name]' >> service_usage_events.csv.wk

    echo $next_url
    i=`expr $i + 1`
    if [ "$next_url" = "null" ]; then
      # echo $next_url
      break
    fi
  done
fi

if [ -e service_usage_events.csv.old ]; then
  diff --new-line-format='%L' service_usage_events.csv.old service_usage_events.csv.wk > service_usage_events.csv
  rm service_usage_events.csv.wk
else
  mv service_usage_events.csv.wk service_usage_events.csv
fi


