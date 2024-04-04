#!/bin/bash

# Script for setting up an SSH tunnel on port 8089 from a local machine to a remote machine.

# Usage instructions
if [ $# -eq 0 ]; then
	echo "Usage: $0 <remote_address>"
	exit 1
fi

# Connect to the remote machine via SSH and set up tunneling
echo "Setting up SSH tunnel to port 8089 on localhost..."
ssh -i "dtt-key-compute.pem" -L 8089:localhost:8089 "$1"
