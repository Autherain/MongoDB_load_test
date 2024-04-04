kubectl delete pod locust-master-populate
kubectl delete deployment locust-worker-deployment-populate
kubectl delete svc master-populate
kubectl delete configmap load-file
kubectl delete configmap settings-file

kubectl create configmap load-file --from-file=mongo_populating.py
kubectl create configmap settings-file --from-file=settings.py
kubectl create -f k3s_populate/master-populate.yaml
kubectl create -f k3s_populate/master-service-populate.yaml
kubectl create -f k3s_populate/worker-deployment-populate.yaml
