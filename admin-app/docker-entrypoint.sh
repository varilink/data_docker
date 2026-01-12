# ------------------------------------------------------------------------------
# admin/docker-entrypoint.sh
# ------------------------------------------------------------------------------

# Entrypoint script for this project's Docker Compose admin service.

# ------

set -e # exit immediately if a command exits with a non-zero status

if [[ ! -f ../database/core.db ]]
then

  # The Django core DB hasn't been created yet so create it now.

  source .venv/bin/activate
  for app_label in 'admin' 'auth' 'contenttypes' 'sessions'
  do
    python3 manage.py migrate $app_label --database core_db
  done
  DJANGO_SUPERUSER_USERNAME=testuser \
  DJANGO_SUPERUSER_PASSWORD=testpass \
  DJANGO_SUPERUSER_EMAIL=testuser@localhost \
  python3 manage.py createsuperuser --database core_db --noinput
  deactivate

fi

# Resynchronise the Django static files folder with the django-static volume,
# which is mapped to /static in the container. That way if the build has been
# altered to use an upgraded version of Django then the django-static volume
# is updated to reflect any changes to the Djano static files.

source .venv/bin/activate
python3 manage.py migrate whatson --database default
python3 manage.py collectstatic --noinput
deactivate

exec uwsgi                                                                     \
  --ini /etc/uwsgi/apps-enabled/data-admin.ini                                 \
  --env DATA_ADMIN_APP_PORT=$DATA_ADMIN_APP_PORT "$@"
