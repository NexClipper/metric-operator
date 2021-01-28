#!/bin/sh

## Run redis server daemon
redis-server --daemonize yes && sleep 1 

REDIS_CMD="/usr/local/bin/redis-cli"
if [[ "$REDIS_KEY" == "" ]]; then REDIS_KEY="kubernetes";fi
if [[ "$REDIS_HOST" == "" ]]; then REDIS_HOST="10.10.33.15";fi
SERVICEACCOUNT="nexc"
K8S_API_SVR="https://kubernetes.default.svc"
K8S_SERVICE_AC="/var/run/secrets/kubernetes.io/serviceaccount"
K8S_NAMESPACE=$(cat ${K8S_SERVICE_AC}/namespace)
K8S_TOKEN=$(cat ${K8S_SERVICE_AC}/token)
K8S_CACERT=${K8S_SERVICE_AC}/ca.crt
##### api list get
apis_list=`curl -sL --cacert ${K8S_CACERT} --header "Authorization: Bearer ${K8S_TOKEN}" -X GET ${K8S_API_SVR}/apis/apps/v1 |jq '.resources[].name' | egrep -v '/' |awk -F "\"" '{print $2}'`
api_list=`curl -sL --cacert ${K8S_CACERT} --header "Authorization: Bearer ${K8S_TOKEN}" -X GET ${K8S_API_SVR}/api/v1 |jq '.resources[].name' | egrep -v '/'|awk -F "\"" '{print $2}'`
#####

## Run script every 10 seconds
while :
do
	echo $(date "+%Y%m%d_%H%M%S") "----------"
########## API json to Redis
# /apis/apps/v1
	for i in $apis_list; do
		curl -sL --cacert ${K8S_CACERT} --header "Authorization: Bearer ${K8S_TOKEN}" -X GET ${K8S_API_SVR}/apis/apps/v1/$i > /tmp/${i}.json
		echo -n "$i : "
		$REDIS_CMD -h ${REDIS_HOST} -x HMSET ${REDIS_KEY} $i < /tmp/${i}.json
	done
# /api/v1
	for x in $api_list; do
		curl -sL --cacert ${K8S_CACERT} --header "Authorization: Bearer ${K8S_TOKEN}" -X GET ${K8S_API_SVR}/api/v1/$x > /tmp/${x}.json
		echo -n "$x : "
		$REDIS_CMD -h ${REDIS_HOST} -x HMSET ${REDIS_KEY} $x < /tmp/${x}.json
	done
# /version
	curl -sL --cacert ${K8S_CACERT} --header "Authorization: Bearer ${K8S_TOKEN}" -X GET ${K8S_API_SVR}/version > /tmp/version.json
	echo -n "version : "
	$REDIS_CMD -h ${REDIS_HOST} -x HMSET ${REDIS_KEY} version </tmp/version.json
########## API json to Redis
	echo "----------------------------"
	sleep 10
done
