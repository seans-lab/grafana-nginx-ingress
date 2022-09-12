# INSTALL KEDA
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda
kubectl apply -f ../6-scaled-objects.yaml 
