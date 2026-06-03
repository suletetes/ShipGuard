#!/bin/bash
set -e

# Start the cloudpulse application via systemd
systemctl start cloudpulse

# Enable the service to start on boot
systemctl enable cloudpulse
