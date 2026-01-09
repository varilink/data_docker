#!/usr/bin/env sh

# ------------------------------------------------------------------------------
# web/config.sh
# ------------------------------------------------------------------------------

# The entrypoint script for the Nginx image looks for shell scripts in the
# /docker-entrypoint.d/ directory and runs them if it finds them. We copy this
# shell script to that directory in order to customise the behaviour of the
# app web service container, which is based on the Nginx image.

# ------

echo 'Running the project Nginx configuration script for the web app service'

if [ "${WORKER_PROCESSES}" ]; then
  echo "Overriding default Nginx worker processes to ${WORKER_PROCESSES}"
  sed -i "s/^worker_processes.*$/worker_processes  ${WORKER_PROCESSES};/"      \
    /etc/nginx/nginx.conf
fi

if [ "${DATA_WEB_ERROR_LOG_LEVEL}" ]; then
  echo "Setting Nginx log level to ${DATA_WEB_ERROR_LOG_LEVEL}"
  log_file='\/var\/log\/nginx\/error.log'
  sed -i "s/^error_log.*$/error_log ${log_file} ${DATA_WEB_ERROR_LOG_LEVEL};/" \
    /etc/nginx/nginx.conf
fi

if [ -z "$( ls -A \"/var/www/${DATA_WEB_HOST}/html/upload/\" )" ]; then
  echo 'Restoring the upload image directory from the backup'
  cp -rp /backup/upload/* /var/www/${DATA_WEB_HOST}/html/upload/
  chown -R www-data:www-data /var/www/${DATA_WEB_HOST}/html/upload/
fi
