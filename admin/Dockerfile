# ------------------------------------------------------------------------------
# admin/Dockerfile
# ------------------------------------------------------------------------------

# Dockerfile for building this project's Docker Compose admin service.

# ------

FROM debian:bookworm
LABEL maintainer='david.williamson@varilink.co.uk'

# Notes pertaining to RUN command below:
#   - rsync is used in order to synchronize the Django static files to where
#     they are required in this container environment only, i.e. it is not
#     needed in the non-container, host build.
#   - We use the mkhomedir command so that the home directory for www-data is
#     populated with the contents of the /etc/skel directory.
#   - The /database and /static directories will be mapped to volumes at runtime
#     but we create them explicitly here rather than let them autocreate at
#     runtime in order to set the correct ownership.

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    python3                                                                    \
    python3-pip                                                                \
    python3-venv                                                               \
    rsync                                                                      \
    uwsgi                                                                      \
    uwsgi-plugin-python3                                                    && \
    usermod --shell /bin/bash www-data                                      && \
    mkhomedir_helper www-data                                               && \
    mkdir /database /static                                                 && \
    chown www-data:www-data /database /static

# Copy the docker-entrypoint.sh script before we lower our permissions by
# switching to the www-data user.

COPY docker-entrypoint.sh /
ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]

# We need to run commands as the www-data user and in its home directory of
# /var/www. We also need to use the bash shell for access to the source command.

USER www-data
WORKDIR /var/www
SHELL ["/bin/bash", "-c"]

# Install Ansible, Django and the Python dateutil module and create the data
# Django project, all within a Python virtual environment. We include Ansible
# here so that we can share Jinja templates in this container environment that
# are also used when we use Ansible to deploy the application to hosts without
# using containers.

RUN                                                                            \
  python3 -m venv .venv                                                     && \
  source .venv/bin/activate                                                 && \
  pip3 install                                                                 \
    ansible==10.4.0                                                            \
    django==5.0.6                                                              \
    python-dateutil==2.9.0.post0                                            && \
  django-admin startproject data                                            && \
  cd data                                                                   && \
  python3 manage.py startapp whatson

# Copy Django configuration files for both the "data" project and the "whatson"
# application from the data_admin repository into this image.

COPY data_admin/data/urls.py data/data/
COPY vars.yml data_admin/data/settings.py.j2 /tmp/
COPY data_admin/whatson/ data/whatson/

# Create the settings.py file using the Ansible template module to process a
# template held in the data_admin repository and vars specific to this container
# environment.

RUN                                                                            \
  source .venv/bin/activate                                                 && \
  ansible --extra-vars @/tmp/vars.yml --module-name template                   \
    --args 'src=/tmp/settings.py.j2 dest=data/data/settings.py' localhost
