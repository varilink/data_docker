# ------------------------------------------------------------------------------
# admin-web/config.sh
# ------------------------------------------------------------------------------

# The entrypoint script for the Nginx image looks for shell scripts in the
# /docker-entrypoint.d/ directory and runs them if it finds them. We copy this
# shell script to that directory in order to customise the behaviour of the
# app web service container, which is based on the Nginx image.

# ------

echo 'Running the project Nginx configuration script for the web admin service'

if [ "${WORKER_PROCESSES}" ]; then
  echo "Overriding default Nginx worker processes to ${WORKER_PROCESSES}"
  sed -i "s/^worker_processes.*$/worker_processes  ${WORKER_PROCESSES};/"      \
    /etc/nginx/nginx.conf
fi
