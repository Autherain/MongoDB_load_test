# BNP INDUSTRIAL PROJECT

## Introduction
The industrial project is a migration project of the operational database from the fraud detection engine of the BNP Paribas banking group, from Cassandra to MongoDB.This migration is imperative to maintain the operability of the rules engine in detecting fraudulent behaviors.

## Module Descriptions
This project consists of 4 folders, each serving a purpose:
- `k3s_installation`: This module installs k3s on the k3s master node as well as kubectl.
- `locust-mongo`: This module contains the code used by Locust to perform its tests.
- `terraform_infrastructure`: This module deploys the AWS EC2 infrastructure.
- `deploy_mongo`: This module installs MongoDB replicas via the MongoDB Kubernetes operator. It also deploys a test pod allowing mongosh in its shell.

## Module Installation Order
!! Always ensure to execute scripts and others in their dedicated modules !!

1. Deploy the AWS infrastructure using Terraform via the `terraform_infrastructure` module.

2. Connect to the shell of the machine you want to be the k3S master node (by default, it's 10.0.1.10).

3. Use the `k3s_installation` module to install k3s and kubectl on your master node. Kubernetes provides a command-line tool to communicate with the control plane of a Kubernetes cluster, using the Kubernetes API.

4. Using the bash script `install_k3s_and_kubectl.sh`, the script will print on the command console the string to copy and paste into the shells of other AWS EC2 machines to install k3s and have them follow the master node. Repeat this for each AWS EC2 machine.

5. Your MongoDB cluster should be ready.

6. Deploy the necessary master and workers for your tests. To populate the MongoDB cluster, simply execute the `redeploy_populate.sh` script. To perform tests, execute the `redeploy_populate.sh` script.
