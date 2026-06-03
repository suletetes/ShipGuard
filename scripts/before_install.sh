#!/bin/bash
set -e

# Stop the cloudpulse service (ignore error if not running)
systemctl stop cloudpulse || true

# Remove all files from the deployment directory
rm -rf /opt/cloudpulse/*

# Ensure the deployment directory exists
mkdir -p /opt/cloudpulse
