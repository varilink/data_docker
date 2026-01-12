# ------------------------------------------------------------------------------
# admin/Dockerfile
# ------------------------------------------------------------------------------

# Dockerfile for building this project's Docker Compose admin service.

# ------

FROM debian:bookworm
LABEL maintainer='david.williamson@varilink.co.uk'

ARG DATA_ADMIN_APP_HOST
ARG DATA_ADMIN_WEB_HOST
ARG DATA_APP_HOST

COPY vars.yml data_admin/data/settings.py.j2 /tmp/

# We need to use the bash shell for access to the source, shell builtin.
SHELL ["/bin/bash", "-c"]

RUN                                                                            \
  # Install system packages
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    gosu                                                                       \
    python3                                                                    \
    python3-pip                                                                \
    python3-venv                                                               \
    uwsgi                                                                      \
    uwsgi-plugin-python3                                                    && \
  # Create the www-data user
  usermod --shell /bin/bash www-data                                        && \
  mkhomedir_helper www-data                                                 && \
  # Create the directory for the Django core database
  mkdir -p /var/www/${DATA_ADMIN_APP_HOST}/database/                        && \
  chown www-data:www-data /var/www/${DATA_ADMIN_APP_HOST}/database          && \
  # Create the directory for the Django static files
  mkdir -p /var/www/${DATA_ADMIN_WEB_HOST}/html/static/                     && \
  # Install Python packages
  mkdir -p /var/www/${DATA_ADMIN_APP_HOST}/django/                          && \
  cd /var/www/${DATA_ADMIN_APP_HOST}/django/                                && \
  python3 -m venv .venv                                                     && \
  source .venv/bin/activate                                                 && \
  pip3 install                                                                 \
    ansible-core==2.19.2                                                       \
    django==5.2.6                                                              \
    python-dateutil==2.9.0.post0                                            && \
  # Create the Django DATA project and WhatsOn application
  django-admin startproject data .                                          && \
  python3 manage.py startapp whatson                                        && \
  export DATA_ADMIN_HOST=${DATA_ADMIN_HOST}                                 && \
  export DATA_ADMIN_WEB_HOST=${DATA_ADMIN_WEB_HOST}                         && \
  export DATA_APP_HOST=${DATA_APP_HOST}                                     && \
  ansible -i localhost, -c local                                               \
    --extra-vars 'ansible_python_interpreter=/usr/bin/python3'                 \
    --extra-vars '@/tmp/vars.yml'                                              \
    --module-name template                                                     \
    --args 'src=/tmp/settings.py.j2 dest=data/settings.py' localhost

# Complete the setup of the Django data project and whatson application.
COPY data_admin/data/urls.py /var/www/${DATA_ADMIN_APP_HOST}/django/data/
COPY data_admin/whatson/*.py /var/www/${DATA_ADMIN_APP_HOST}/django/whatson/
COPY data_admin/whatson/migrations/*.py                                        \
  /var/www/${DATA_ADMIN_APP_HOST}/django/whatson/migrations/

# Set up the Docker entrypoint and its context.
COPY docker-entrypoint.sh /
ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]
WORKDIR /var/www/${DATA_ADMIN_APP_HOST}/django/
