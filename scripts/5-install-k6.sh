# Install K6
kubectl create namespace k6
kubectl config set-context --current --namespace=k6
git clone https://github.com/grafana/k6-operator && cd k6-operator
make deploy
kubectl config set-context --current --namespace=cafe
kubectl create configmap crocodile-stress-test --from-file ../k6-test.js
