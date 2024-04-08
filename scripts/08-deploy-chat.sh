#!/bin/bash

# For more information, see https://azure.github.io/azure-workload-identity/docs/quick-start.html

# Variables
source ./00-variables.sh

# Attach ACR to AKS cluster
if [[ $attachAcr == true ]]; then
  echo "Attaching ACR $acrName to AKS cluster $aksClusterName..."
  az aks update \
  --name $aksClusterName \
  --resource-group $aksResourceGroupName \
  --attach-acr $acrName
fi

# Create the namespace if it doesn't already exists in the cluster
result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
  echo "[$namespace] namespace already exists in the cluster"
else
  echo "[$namespace] namespace does not exist in the cluster"
  echo "creating [$namespace] namespace in the cluster..."
  kubectl create namespace $namespace
fi

# Create configmap
cat chat-configmap.yml |
yq "(.data.USE_LOCAL_LLM)|="\""$useLocalLlm"\" |
yq "(.data.AI_ENDPOINT)|="\""$inferenceEndpointUrl"\" |
kubectl apply -n $namespace -f -

# Create deployment
cat chat-deployment.yml |
yq "(.spec.template.spec.containers[0].image)|="\""$acrName.azurecr.io/$chatImageName:$tag"\" |
yq "(.spec.template.spec.containers[0].imagePullPolicy)|="\""$imagePullPolicy"\" |
yq "(.spec.template.spec.serviceAccountName)|="\""$serviceAccountName"\" |
kubectl apply -n $namespace -f -

# Create service
kubectl apply -f chat-service.yml -n $namespace

# Create HTTP ingress
cat chat-ingress.yml |
yq "(.metadata.name)|="\""$chatIngressName"\" |
yq "(.spec.tls[0].hosts[0])|="\""$chatHostName"\" |
yq "(.spec.tls[0].secretName)|="\""$chatSecretName"\" |
yq "(.spec.rules[0].host)|="\""$chatHostName"\" |
yq "(.spec.rules[0].http.paths[0].backend.service.name)|="\""$chatServiceName"\" |
yq "(.spec.rules[0].http.paths[0].backend.service.port.number)|=$chatServicePort" |
kubectl apply -n $namespace -f -