# INSTALL GRAFANA & PROMETHEUS
kubectl create namespace grafana
kubectl config set-context --current --namespace=grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus-kube prometheus-community/kube-prometheus-stack
helm install prometheus prometheus-community/prometheus
