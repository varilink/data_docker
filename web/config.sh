#!/usr/bin/env sh

# ------------------------------------------------------------------------------
# web/config.sh
# ------------------------------------------------------------------------------

# The entrypoint script for the Nginx image looks for shell scripts in the
# /docker-entrypoin.d/ directory and runs them if it finds them. We copy this
# shell script to that directory in order to customise the behaviour of the
# web service container, which is based on the Nginx image.

# ------

echo 'Running the project Nginx configuration script'

if [ "${WORKER_PROCESSES}" ]; then
  echo "Overriding default Nginx worker processes to ${WORKER_PROCESSES}"
  sed -i "s/^worker_processes.*$/worker_processes  ${WORKER_PROCESSES};/"      \
    /etc/nginx/nginx.conf
fi

if [ "${ERROR_LOG_LEVEL}" ]; then
  echo "Setting Nginx log level to ${ERROR_LOG_LEVEL}"
  log_file='\/var\/log\/nginx\/error.log'
  sed -i "s/^error_log.*$/error_log  ${log_file} ${ERROR_LOG_LEVEL};/"         \
    /etc/nginx/nginx.conf
fi

if [ -d /upload ]
then
  echo 'Upload image directory already exists so skipping restore from backup'
else
  echo 'Restoring the upload image directory from the backup'
  cp -rp /backup/upload /
  chown -R www-data:www-data /upload
fi
