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

<img src="https://github.com/seans-lab/grafana-nginx-ingress/blob/main/images/GCloud1.png"
/>

Find the cluster name according to your deployment configuration specified in your Terraform Configuration and click on the name hyperlink.

Click on the 'Connect' button on the top of the window and select your preferred connection method to access the Kubernetes Management instance.

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

## Install Cafe App
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

I have greated an ingress resource to view the Prometheus Agent and see what kinkd of metrics are available from the Ingress Controller.

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout prometheus-tls.key -out prometheus-tls.crt -subj "/CN=prometheus.example.com"
kubectl create secret tls prometheus-tls --key="prometheus-tls.key" --cert="prometheus-tls.crt"
kubectl apply -f prometheus-ingress.yaml
```

Install the kube-promethus stack specifically designed for Kubernetes Monitoring.
```
helm install prometheus-kube prometheus-community/kube-prometheus-stack
```
We can now create an ingress resource for the Grafana Dashboard to be able to access it externally.

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout grafana-tls.key -out grafana-tls.crt -subj "/CN=grafana.example.com"
kubectl create secret tls grafana-tls --key="grafana-tls.key" --cert="grafana-tls.crt"
kubectl apply -f grafana-ingress.yaml
```


Visit https://grafana.example.com in your web browser.
Username: admin
Password: prom-operator


## Dashboard Navigation

In the top Left Side select the Dashboard Icon and select browse. There will be a series of dashboards available for you to navigate through.

## Add the NGINX Ingress Controller Dashboard

On the top left of the window select the Dashboard icon and click on the Import Button.

Copy the content of the nginx-dashboard.json file and paste it in the 

## Ingress Load

### Keda

#### Keda's Function 

#### Configuration

### K6

#### What is K6 
Grafana k6 is an open-source load testing tool that makes performance testing easy and productive for engineering teams. k6 is free, developer-centric, and extensible.

Using k6, you can test the reliability and performance of your systems and catch performance regressions and problems earlier. k6 will help you to build resilient and performant applications that scale.

#### K6 Operator

The operator pattern is a way of extending Kubernetes so that you may use custom resources to manage applications running in the cluster. The pattern aims to automate the tasks that a human operator would usually do, like provisioning new application components, changing the configuration, or resolving problems that occur.

This is accomplished using custom resources which, for the scope of this article, could be compared to the traditional service requests that you would file to your system operator to get changes applied to the environment.

```
git clone https://github.com/grafana/k6-operator && cd k6-operator
kubectl create namespace k6
kubectl config set-context --current --namespace=k6
make deploy
```

#### Config Map

Once the test script is done, we have to deploy it to the kubernetes cluster. We’ll use a ConfigMap to accomplish this. The name of the map can be whatever you like, but for this demo we'll go with crocodile-stress-test.

```
apiVersion: k6.io/v1alpha1
kind: K6
metadata:
  name: k6-sample
spec:
  parallelism: 4
  script:
    configMap:
      name: crocodile-stress-test
      file: k6-test.js



```

#### Test Scripts.

```
// Creator: k6 Browser Recorder 0.6.0

import { sleep, group } from 'k6'
import http from 'k6/http'

export const options = { vus: 100, duration: '3m', insecureSkipTLSVerify: true }

export default function main() {
  let response

  group('page_1 - http://coffee-svc', function () {
    response = http.get('http://coffee-svc', {
      headers: {
        host: 'coffee-svc',
        accept:
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'accept-language': 'en-US,en;q=0.5',
        'accept-encoding': 'gzip, deflate, br',
        connection: 'keep-alive',
        'upgrade-insecure-requests': '1',
        'sec-fetch-dest': 'document',
        'sec-fetch-mode': 'navigate',
        'sec-fetch-site': 'none',
        'sec-fetch-user': '?1',
        'sec-gpc': '1',
      },
    })
    sleep(6.3)
  })

  group('page_2 - http://tea-svc', function () {
    response = http.get('http://tea-svc', {
      headers: {
        host: 'tea-svc',
        accept:
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'accept-language': 'en-US,en;q=0.5',
        'accept-encoding': 'gzip, deflate, br',
        connection: 'keep-alive',
        'upgrade-insecure-requests': '1',
        'sec-fetch-dest': 'document',
        'sec-fetch-mode': 'navigate',
        'sec-fetch-site': 'none',
        'sec-fetch-user': '?1',
        'sec-gpc': '1',
      },
    })
  })
}
```

## Troubleshooting
