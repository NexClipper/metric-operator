#!/bin/sh

## Run redis server daemon
redis-server --daemonize yes && sleep 1 

## Run script forever
while true; 
  do kubectl get all -A -o json > state.json && redis-cli -x set k8s_state < state.json;
  sleep 10; 
done
