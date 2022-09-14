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
Once the GKE deployment is complete. Login to your GCP via your web browser and select the Kubernetes Engine --> Clusters from the service selection drop Down Menue on the top left hand side of the window.

<img src="https://github.com/seans-lab/grafana-nginx-ingress/blob/main/images/GCloud1.png" width=50%
/>

Find the cluster name according to your deployment configuration specified in your Terraform Configuration and click on the name hyperlink.

<img src="https://github.com/seans-lab/grafana-nginx-ingress/blob/main/images/GCloud2.png" width=75%
/>

Click on the 'Connect' button on the top of the window and select your preferred connection method to access the Kubernetes Management instance.

<img src="https://github.com/seans-lab/grafana-nginx-ingress/blob/main/images/GCloud3.png" width=75%
/>

TIP: For easy access use the browser shell.


## Deploying the NGINX Ingress Controller using HELM

Add the Helm Repository and install the ingress controller with the flags to enable the prometheus exporter.
```
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install nginx-release nginx-stable/nginx-ingress --set prometheus.create=true --set prometheus.port=9113 --set prometheus.scheme=http
```
Documentation Page: https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/

## Install Cafe App
```
git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v2.3.0
cd kubernetes-ingress/examples/complete-example
cd ../../../
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe-secret.yaml
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe.yaml
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe-ingress.yaml
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
kubectl apply -f 4-prometheus-ingress.yaml
```

Install the kube-promethus stack specifically designed for Kubernetes Monitoring.
```
helm install prometheus-kube prometheus-community/kube-prometheus-stack
```
We can now create an ingress resource for the Grafana Dashboard to be able to access it externally.

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout grafana-tls.key -out grafana-tls.crt -subj "/CN=grafana.example.com"
kubectl create secret tls grafana-tls --key="grafana-tls.key" --cert="grafana-tls.crt"
kubectl apply -f 5-grafana-ingress.yaml
```


Visit https://grafana.example.com in your web browser.

Username: admin

Password: prom-operator



## Dashboard Navigation

In the top Left Side select the Dashboard Icon and select browse. There will be a series of dashboards available for you to navigate through.

<img src="https://github.com/seans-lab/grafana-nginx-ingress/blob/main/images/Grafana1.png" width=50%
/>

## Add the NGINX Ingress Controller Dashboard

On the top left of the window select the Dashboard icon and click on the Import Button.

<img src="https://github.com/seans-lab/grafana-nginx-ingress/blob/main/images/Grafana2.png" width=25%
/>

Copy the content of the nginx-dashboard.json file and paste it in the 

<img src="https://github.com/seans-lab/grafana-nginx-ingress/blob/main/images/Grafana3.png" width=50%
/>

## Create Data Source for NGINX Ingress Controller Prometheus Instance


## Ingress Load

### Keda
All About Keda
https://keda.sh/


#### Keda's Function 



KEDA is a Kubernetes-based Event Driven Autoscaler. With KEDA, you can drive the scaling of any container in Kubernetes based on the number of events needing to be processed.

KEDA is a single-purpose and lightweight component that can be added into any Kubernetes cluster. KEDA works alongside standard Kubernetes components like the Horizontal Pod Autoscaler and can extend functionality without overwriting or duplication. With KEDA you can explicitly map the apps you want to use event-driven scale, with other apps continuing to function. This makes KEDA a flexible and safe option to run alongside any number of any other Kubernetes applications or frameworks.

#### Keda Installation


```
#INSTALL KEDA
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda
kubectl apply -f 6-scaled-objects.yaml 
```

#### Configuration

```
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
 name: nginx-scale
spec:
 scaleTargetRef:
   kind: Deployment
   name: main-nginx-ingress
 minReplicaCount: 1
 maxReplicaCount: 20
 cooldownPeriod: 30
 pollingInterval: 1
 triggers:
 - type: prometheus
   metadata:
     serverAddress: http://prometheus-server
     metricName: nginx_connections_active_keda
     query: |
       sum(avg_over_time(nginx_ingress_nginx_connections_active{app="main-nginx-ingress"}[1m]))
     threshold: "100"
```

### K6

#### What is K6 
Grafana k6 is an open-source load testing tool that makes performance testing easy and productive for engineering teams. k6 is free, developer-centric, and extensible.

Using k6, you can test the reliability and performance of your systems and catch performance regressions and problems earlier. k6 will help you to build resilient and performant applications that scale.

#### K6 Operator

The operator pattern is a way of extending Kubernetes so that you may use custom resources to manage applications running in the cluster. The pattern aims to automate the tasks that a human operator would usually do, like provisioning new application components, changing the configuration, or resolving problems that occur.

This is accomplished using custom resources which, for the scope of this article, could be compared to the traditional service requests that you would file to your system operator to get changes applied to the environment.

```
git clone https://github.com/grafana/k6-operator && cd k6-operator
make deploy
```

#### Deploying our test script

Once the test script is done, we have to deploy it to the kubernetes cluster. We’ll use a ConfigMap to accomplish this. The name of the map can be whatever you like, but for this demo we'll go with crocodile-stress-test.

Once the test script is done, we have to deploy it to the kubernetes cluster. We’ll use a ConfigMap to accomplish this. The name of the map can be whatever you like, but for this demo we'll go with cafe-stress-test.

```
kubectl create configmap cafe-stress-test --from-file k6-test.js
```

The config map contains the content of our test file, labelled as test.js. The operator will later search through our config map for this key, and use its content as the test script.

#### Creating our custom resource (CR)

To communicate with the operator, we’ll use a custom resource called K6. Custom resources behave just as native Kubernetes objects, while being fully customizable. 

```
cd ../
kubectl apply -f 7-k6-test.yaml
```

In this case, the data of the custom resource contains all the information necessary for k6 operator to be able to start a distributed load test:

```
apiVersion: k6.io/v1alpha1
kind: K6
metadata:
  name: k6-sample
spec:
  parallelism: 4
  script:
    configMap:
      name: cafe-stress-test
      file: k6-test.js



```

#### Test Script.

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

- Check Comments
- Join the Slack Community
- Follow Social Groups
- GitHub
- Hit us up on LinkedIn


