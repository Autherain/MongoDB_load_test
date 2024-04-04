# deploy_mongo

## Deploying MongoDB Replicas
To deploy MongoDB replicas, simply execute the script `deploy_replicas_mongo.sh`.

I invite you to refer to the Kubernetes MongoDB Operator documentation available at `https://github.com/mongodb/mongodb-kubernetes-operator/blob/master/docs/deploy-configure.md` to understand the content of the script.

## Test Pod
To test the connectivity of your MongoDB cluster and its replicas, you can use `test-mongo.yml` to deploy a pod containing mongosh in its shell.

The connection string to your cluster can be obtained by attaching to the shell of the `test-mongo.yml` pod and then using `mongosh`.
If you decide not to change the contents of the manifests presented here, the connection string is:
```
mongodb+srv://my-user:123@example-mongodb-svc.default.svc.cluster.local/admin?replicaSet=example-mongodb&ssl=false
```

To find this connection string, I invite you to refer to the Kubernetes MongoDB Operator documentation available at `https://github.com/mongodb/mongodb-kubernetes-operator/blob/master/docs/deploy-configure.md`.
