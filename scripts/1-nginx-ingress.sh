# Install NGINX Ingress
kubectl create namespace nginx-ingress
kubectl config set-context --current --namespace=nginx-ingress
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install nginx-release nginx-stable/nginx-ingress --set prometheus.create=true --set prometheus.port=9113 --set prometheus.scheme=http
