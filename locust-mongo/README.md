## Generating MongoDB Workloads with Locust

Generating MongoDB Workloads with Locust

Locust is an easy-to-use, scriptable, and scalable performance testing tool written in Python. It allows you to easily code MongoDB operations in pure Python and visualize their execution in a browser by plotting the number of requests per second and real-time p50 and p95 latencies.

Locust can run on a laptop in standalone mode. It requires almost no configuration and is easy to get started with. However, when needed, Locust can be run in distributed mode - with a single primary aggregating and exposing statistics and multiple workers capable of executing thousands of requests per second on your MongoDB deployments.

This is a basic template that can be extended to build a custom workload. It contains the necessary basic code to get started. Example functions for inserting new documents (single and bulk), executing searches, and aggregation pipelines are also implemented for reference.

To get started, you need to have python 3 and git installed. On Amazon Linux 2, this can be done using the following commands:
```shell
sudo yum install git -y
sudo yum install python3 -y
```

Create the virtual environment and install prerequisites using the following commands:
```shell
cd mongolocust
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Once the prerequisites are installed, you need to update the cluster credentials in settings.py to match your MongoDB deployment and copy your modified load_test.py.

The test can be started locally in standalone mode using the following command:

```shell
(locust) adilet@MBP16 mongolocust % locust -f load_test.py
[2021-08-15 20:33:45,238] MBP16.local/INFO/locust.main: Starting web interface at http://0.0.0.0:8089 (accepting connections from all network interfaces)
[2021-08-15 20:33:45,247] MBP16.local/INFO/locust.main: Starting Locust 2.1.0
```

Finally, you can open the browser and access http://127.0.0.1:8089 to start the test.
## Running Locust in Distributed Mode

Locust can be run in distributed mode, where the primary instance controls the workload, exposes a client GUI, and gathers statistics from multiple worker instances running tests. This mode is necessary for generating higher throughput. The primary and workers can be placed in the same region as the Atlas cluster's cloud provider to minimize network latencies.

The required steps to run the primary instance:

```shell
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

The correct workload file must be copied, and the connection string must be modified in settings.py.

Finally, the primary instance can be started as follows:

```shell
./run_distributed_primary.sh
```

Please note the primary's IP address as it will be needed to access the graphical user interface as well as to configure workers. Workers use the same default TCP port, 8089, to establish a connection to the primary.

The required steps to run a worker (can be repeated multiple times on multiple VMs):

```shell
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Worker instances can be started using the following command (the IP address <PRIMARY_HOST_IP> must be replaced with the correct IP address from the previous step):

```shell
./run_distributed_worker.sh <PRIMARY_HOST_IP>
```

You can run multiple instances of the worker on each machine, as workers are single-threaded. Multiple machines can be used to run workers.

## Running Distributed Locust in Kubernetes

Distributed Locust can be run in Kubernetes environments. Using Kubernetes allows simple scalability of workers in distributed mode. Please refer to the README.md in the k3s folder for more details.
