#!/bin/bash

# Fix access docker.sock for our dashboard.
if [ -f /var/run/docker.sock ]; then
  chown apache:www-data /var/run/docker.sock
fi

# Set uid/gid to fix data permissions.
if [ "$LOCAL_UID" != "" ]; then
  /scripts/change_uid_gid.sh apache:www-data $LOCAL_UID:$LOCAL_GID
fi

# Apache yelling about pid on container restart.
rm -rf /run/apache2
mkdir -p /run/apache2
chown apache:www-data /run/apache2

echo "[i] Starting Apache..."
# Run apache httpd daemon.
httpd -D FOREGROUND

# Test if apache is running, if not send error.
sleep 1s
if ! pgrep -x "httpd" > /dev/null
then
  echo "[i] Apache stopped..."
  tail -n 5 /var/log/apache2/error.log
  if [ -f /var/log/apache2/ssl_error.log ]; then
    tail -n 5 /var/log/apache2/ssl_error.log
  fi
  exit 0;
fi

echo "[i] Apache running!"
