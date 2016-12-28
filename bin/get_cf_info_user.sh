#! /bin/bash

#古いファイルを退避
if [ -e app_usage_events.csv ]; then
  mv app_usage_events.csv app_usage_events.csv.old
fi

# 最初
cf curl '/v2/app_usage_events?order-direction=asc&page=1&results-per-page=50' > tmp_app_usage.json

next_url="`cat tmp_app_usage.json | jq -c '.next_url'`"

echo "$next_url"


cat tmp_app_usage.json | jq -c '.resources[] |[.metadata.created_at, .entity.app_name, .entity.space_name, .entity.state, .entity.previous_state, .entity.instance_count, .entity.memory_in_mb_per_instance, .entity.previous_instance_count, .entity.previous_memory_in_mb_per_instance]' > app_usage_events.csv.wk


# 残り 500はリミッター※　仕様が変わったとかで無限に陥らないため

i=0
while [ $i -ne 500 ]; do

  command="cf curl ${next_url} > tmp_app_usage.json"
  eval ${command}

  next_url="`cat tmp_app_usage.json | jq -c '.next_url'`"

  cat tmp_app_usage.json | jq -c '.resources[] |[.metadata.created_at, .entity.app_name, .entity.space_name, .entity.state, .entity.previous_state, .entity.instance_count, .entity.memory_in_mb_per_instance, .entity.previous_instance_count, .entity.previous_memory_in_mb_per_instance]' >> app_usage_events.csv.wk

  echo $next_url
  i=`expr $i + 1`
  if [ "$next_url" = "null" ]; then
    # echo $next_url
    break
  fi
done

if [ -e app_usage_events.csv.old ]; then
  diff --new-line-format='%L' app_usage_events.csv.old app_usage_events.csv.wk > app_usage_events.csv
  rm app_usage_events.csv.wk
else
  mv app_usage_events.csv.wk app_usage_events.csv
fi


