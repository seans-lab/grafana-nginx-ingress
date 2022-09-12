# Install Cafe Demo App 
kubectl create namespace cafe
kubectl config set-context --current --namespace=cafe
git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v2.3.0
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe-secret.yaml -n cafe
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe.yaml -n cafe
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe-ingress.yaml -n cafe
