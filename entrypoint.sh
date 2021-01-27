#!/bin/bash

## Run redis server daemon
redis-server --daemonize yes && sleep 1 

## Run script every 10 seconds
REDISCMD="redis-cli"
SERVICEACCOUNT="nexc"
KEY="kubernetes"
K8S_API_SVR="https://kubernetes.default.svc"
SERVICEAC="/var/run/secrets/kubernetes.io/serviceaccount"
K8S_NAMESPACE=$(cat ${SERVICEAC}/namespace)
K8S_TOKEN=$(cat ${SERVICEAC}/token)
K8S_CACERT=${SERVICEAC}/ca.crt
REDIS_HOST="localhost"
## Set API Lists
APILIST=(namespaces events configmaps secrets nodes pods services persistentvolumeclaims persistentvolumes replicasets daemonsets deployments)
APILIST_DIR[0]="/api/v1/namespaces"
APILIST_DIR[1]="/api/v1/events"
APILIST_DIR[2]="/api/v1/configmaps"
APILIST_DIR[3]="/api/v1/secrets"
APILIST_DIR[4]="/api/v1/nodes"
APILIST_DIR[5]="/api/v1/pods"
APILIST_DIR[6]="/api/v1/services"
APILIST_DIR[7]="/api/v1/persistentvolumeclaims"
APILIST_DIR[8]="/api/v1/persistentvolumes"
APILIST_DIR[9]="/apis/apps/v1/replicasets"
APILIST_DIR[10]="/apis/apps/v1/daemonsets"
APILIST_DIR[11]="/apis/apps/v1/deployments"
######################
echo -n "VVVVVVVVVVV : "
$REDISCMD --version
while : 
do 
  for i in ${!APILIST[@]}; do
        echo -n -e ${APILIST[$i]} ": "
        curl -sL --cacert ${K8S_CACERT} --header "Authorization: Bearer ${K8S_TOKEN}" -X GET ${K8S_API_SVR}${APILIST_DIR[$i]} > temp
        $REDISCMD -h ${REDIS_HOST} -x HMSET ${KEY} ${APILIST[$i]} < temp
  done
  sleep 10; 
done
