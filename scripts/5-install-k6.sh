# Install K6
git clone https://github.com/grafana/k6-operator && cd k6-operator
make deploy
cd ../
kubectl create configmap cafe-stress-test --from-file k6-test.js
kubectl apply -f 7-k6-test.yaml
