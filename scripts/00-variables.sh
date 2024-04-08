# Variables

# Azure Subscription and Tenant
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)
tenantId=$(az account show --query tenantId --output tsv)

# Azure Container Registry
prefix="Atum"
acrName="${prefix,,}acr"
acrResourceGrougName="${prefix}RG"

# Python Files
chatAppFile="chat.py"

# Docker Images
chatImageName="kaitochat"
tag="v1"
port="8000"

# Arrays
images=($chatImageName)
filenames=($chatAppFile)
imagePullPolicy="Always"

# NGINX
nginxNamespace="ingress-basic"
nginxRepoName="ingress-nginx"
nginxRepoUrl="https://kubernetes.github.io/ingress-nginx"
nginxChartName="ingress-nginx"
nginxReleaseName="nginx-ingress"
nginxReplicaCount=3

# Azure DNS
dnsZoneName="babosbird.com"
dnsZoneResourceGroupName="dnsresourcegroup"
chatSubdomain="atumchat"
falconSubdomain="atumfalcon"

# Namespace
namespace="kaito-demo"
serviceAccountName="kaito-sa"

# ConfigMap values
configMapName="openai"
aspNetCoreEnvironment="Production"

# Chat Ingress 
chatIngressName="kaito-chat"
chatIngressTemplate="chat-ingress.yml"
chatSecretName="kaito-chat-tls"
chatHostName="${chatSubdomain,,}.${dnsZoneName,,}"
chatServiceName="kaito-chat"
chatServicePort="80"

# Falcon Ingress
falconIngressName="kaito-falcon"
falconIngressTemplate="falcon-ingress.yml"
falconSecretName="kaito-falcon-tls"
falconHostName="${falconSubdomain,,}.${dnsZoneName,,}"
falconServiceName="workspace-falcon-7b-instruct"
falconServicePort="80"

# Falcon Inference Endpoint Service
useLocalLlm="True"
inferenceEndpointUrl="http://workspace-falcon-7b-instruct/chat"