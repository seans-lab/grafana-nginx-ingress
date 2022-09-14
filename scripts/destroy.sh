kubectl delete -f 6-scaled-objects.yaml 
helm uninstall keda kedacore/keda
helm uninstall prometheus-kube prometheus-community/kube-prometheus-stack
helm uninstall prometheus prometheus-community/prometheus
kubectl delete -f kubernetes-ingress/examples/complete-example/cafe-secret.yaml
kubectl delete -f kubernetes-ingress/examples/complete-example/cafe.yaml
kubectl delete -f kubernetes-ingress/examples/complete-example/cafe-ingress.yaml
helm uninstall nginx-release nginx-stable/nginx-ingress
