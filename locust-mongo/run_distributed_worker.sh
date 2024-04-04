MASTER_HOST=$1
nohup locust -f load_test.py --worker --master-host=$MASTER_HOST >worker1.log &
nohup locust -f load_test.py --worker --master-host=$MASTER_HOST >worker2.log &
