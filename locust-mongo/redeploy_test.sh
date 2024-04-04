kubectl delete pod locust-master-test
kubectl delete deployment locust-worker-deployment-test
kubectl delete svc master
kubectl delete configmap load-file
kubectl delete configmap settings-file

kubectl create configmap load-file --from-file=load_test.py
kubectl create configmap settings-file --from-file=settings.py
kubectl create -f k3s_test/master-test.yaml
kubectl create -f k3s_test/master-service-test.yaml
kubectl create -f k3s_test/worker-deployment-test.yaml
