# Install Cafe Demo App 
git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v2.3.0
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe-secret.yaml
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe.yaml
kubectl apply -f kubernetes-ingress/examples/complete-example/cafe-ingress.yaml
