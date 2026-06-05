#!/bin/bash
set -e

# Create the cloudpulse application user if it doesn't exist
id -u cloudpulse &>/dev/null || useradd -r -s /sbin/nologin cloudpulse

# Install production dependencies
cd /opt/cloudpulse && npm ci --production

# Install the systemd service file
cp /opt/cloudpulse/cloudpulse.service /etc/systemd/system/cloudpulse.service
systemctl daemon-reload

# Set ownership to the dedicated application user
chown -R cloudpulse:cloudpulse /opt/cloudpulse

# Set read/execute permissions
chmod -R 755 /opt/cloudpulse
