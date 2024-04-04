#!/bin/bash
# Script to deploy MongoDB Kubernetes Operator and associated resources

# Clone the MongoDB Kubernetes Operator repository
git clone https://github.com/mongodb/mongodb-kubernetes-operator.git

# Change directory to the cloned repository
cd mongodb-kubernetes-operator/

# Apply the Custom Resource Definitions (CRDs) for MongoDB
kubectl apply -f config/crd/bases/mongodbcommunity.mongodb.com_mongodbcommunity.yaml

# Print a message to verify that the CRDs installed successfully
echo "Verify that the Custom Resource Definitions installed successfully"
kubectl get crd/mongodbcommunity.mongodbcommunity.mongodb.comkubectl get crd/mongodbcommunity.mongodbcommunity.mongodb.com

# Apply Role-Based Access Control (RBAC) resources
kubectl apply -k config/rbac/

# Retrieve and display Role, RoleBinding, and ServiceAccount associated with the MongoDB Kubernetes Operator
kubectl get role mongodb-kubernetes-operator
kubectl get rolebinding mongodb-kubernetes-operator
kubectl get serviceaccount mongodb-kubernetes-operator

# Create the manager pod
kubectl create -f config/manager/manager.yaml

# Print a message to verify that the manager pod was successfully installed
echo "Verify that pod were successfully installed"
kubectl get pods

# Deploy the replica set
echo "Deploying the replica set"
cd ..
kubectl apply -f mongodb.com_v1_mongodbcommunity_cr_podantiaffinity.yaml
