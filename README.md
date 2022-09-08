# Oberving the NGINX Ingress Controller (kubernetes) with Grafana on GKE
Requirements:
- Google Cloud Account with CLI Access
- Terraform (Optional) [https://github.com/hashicorp/learn-terraform-provision-gke-cluster.git](https://github.com/hashicorp/learn-terraform-provision-gke-cluster)
- Kubectl Master Node 
- Git
- Helm

The purpose of this repository is to provide education on how to deploy the NGINX Ingress Controller on Google Kubernetes Engine (GKE) with Prometheus and Grafana as the Observerability layer for NGINX Ingress Controller Resouces and other Kubernetes resouces.

## GKE Deployment using Hashicorp's Terraform

[https://github.com/hashicorp/learn-terraform-provision-gke-cluster.git](https://github.com/hashicorp/learn-terraform-provision-gke-cluster)

## Managing your Kubernetes Cluster via the Google Cloud Management Portal.
Once the GKE deployment is complete. Login to your GCP via your web browser and select the Kubernetes Engine --> Clusters from the service selection drop Down Menue on the top right hand side of the window.


Find the cluster name according to your deployment configuration specified in your Terraform Configuration and click on the name hyperlink.

Click on the SSH option on the top left side of the window and select your preferred SSH method to access the Kubernetes Management instance.

TIP: For easy access use the browser shell.


## Deploying the NGINX Ingress Controller using HELM
Create the nginx-ingress namespace and set the configuration file to use the nginx-ingress namespace context.
```
kubectl create namespace nginx-ingress
kubectl config set-context --current --namespace=nginx-ingress
```
Add the Helm Repository and install the ingress controller with the flags to enable the prometheus exporter.
```
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install nginx-release nginx-stable/nginx-ingress --set prometheus.create=true --set prometheus.port=9113 --set prometheus.scheme=http
```
Documentation Page: https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/

## INSTALL CAFE APP
```
kubectl create namespace cafe
kubectl config set-context --current --namespace=cafe
git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v2.3.0
cd kubernetes-ingress/examples/complete-example
cd ../../../
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe-secret.yaml -n cafe
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe.yaml -n cafe
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe-ingress.yaml -n cafe
```

## Deploying the Prometheus and Grafana Stack using HELM
Create the Grafana Namespace and set your configuration to use that namespace.
```
kubectl create namespace grafana
kubectl config set-context --current --namespace=grafana
```
Add the Helm Repository for Prometheus.
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Install the Prometheus Agent pod for the NGINX Ingress Controller
```
helm install prometheus prometheus-community/prometheus
```

Install the kube-promethus stack specifically designed for Kubernetes Monitoring.
```
helm install prometheus-kube prometheus-community/kube-prometheus-stack
```

## DNS

Once all components ahev been deployed, you will need to add an entry for the following names in your /etc/hosts (Windows: C:\Windows\System32\drivers\etc) file. But first you will need to get the External IP for the ingress controller. On your Browser Shell execute the followig command.

```
kubectl get svc -n nginx-ingress
```

```
cafe.example.com
grafana.example.com
prometheus.example.com
```

## Troubleshooting
