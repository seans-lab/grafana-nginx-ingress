# Oberving the NGINX Ingress Controller (kubernetes) with Grafana on GKE
Requirements:
- Google Cloud Account with CLI Access
- Terraform (Optional) [https://github.com/hashicorp/learn-terraform-provision-gke-cluster.git](https://github.com/hashicorp/learn-terraform-provision-gke-cluster)
- Kubectl Master Node 
- Git
- Helm

The purpose of this repository is to provide education on how to deploy the NGINX Ingress Controller on Google Kubernetes Engine (GKE) with Prometheus and Grafana as the Observerability layer for NGINX Ingress Controller Resouces and other Kubernetes resouces.

## Architecture

## GKE Deployment using Hashicorp's Terraform

## Deploying the NGINX Ingress Controller using HELM

```
kubectl create namespace nginx-ingress
kubectl config set-context --current --namespace=nginx-ingress
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install nginx-release nginx-stable/nginx-ingress --set prometheus.create=true --set prometheus.port=9113 --set prometheus.scheme=http
```

Deploy the NGINX Ingress Controler using HELM by following the documentation on the following page.
https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/

## Deploying the Prometheus and Grafana Stack using HELM

## Troubleshooting
