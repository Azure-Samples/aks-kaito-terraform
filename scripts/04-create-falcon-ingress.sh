#!/bin/bash

# Variables
source ./00-variables.sh

# Create HTTP ingress
cat chat-ingress.yml |
yq "(.metadata.name)|="\""$falconIngressName"\" |
yq "(.spec.tls[0].hosts[0])|="\""$falconHostName"\" |
yq "(.spec.tls[0].secretName)|="\""$falconSecretName"\" |
yq "(.spec.rules[0].host)|="\""$falconHostName"\" |
yq "(.spec.rules[0].http.paths[0].backend.service.name)|="\""$falconServiceName"\" |
yq "(.spec.rules[0].http.paths[0].backend.service.port.number)|=$falconServicePort" |
kubectl apply -n $namespace -f -