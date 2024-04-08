#!/bin/bash

# For more information, see https://docs.microsoft.com/en-us/azure/aks/ai-toolchain-operator

# Variables
source ./00-variables.sh

serviceName="workspace-falcon-7b-instruct"

# Check your service and get the service IP address using the kubectl get svc command.
serviceIp=$(kubectl get svc -n $namespace $serviceName -o jsonpath='{.spec.clusterIP}')

# Run the Falcon 7B-instruct model with a sample input of your choice using the following curl command
kubectl run -it --rm -n $namespace --restart=Never curl --image=curlimages/curl -- curl -X POST http://$serviceIp/chat -H "accept: application/json" -H "Content-Type: application/json" -d "{\"prompt\":\"Tell me about Tuscany and its cities.\", \"return_full_text\": false,  \"generate_kwargs\": {\"max_length\":4096}}"