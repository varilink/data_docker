FROM debian:bookworm
LABEL maintainer='david.williamson@varilink.co.uk'

# NOTE: rsync is only required in this container environment
RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    python3-pip                                                                \
    python3                                                                    \
    rsync                                                                      \
    uwsgi                                                                      \
    uwsgi-plugin-python3                                                    && \
  pip3 install                                                                 \
    django==3.2.4                                                              \
    python-dateutil==2.8.1                                                  && \
  django-admin startproject data

WORKDIR /data

# 1. Migrate to build the Django core database
# 2. Create a superuser to use fir Django admin
# 3. Create the whatson application
RUN                                                                            \
  python3 manage.py migrate                                                 && \
  DJANGO_SUPERUSER_USERNAME=testuser                                           \
  DJANGO_SUPERUSER_PASSWORD=testpass                                           \
  DJANGO_SUPERUSER_EMAIL=testuser@localhost                                    \
  python3 manage.py createsuperuser --noinput                               && \
  python3 manage.py startapp whatson

COPY data-admin/data/*.py data/
COPY data-admin/whatson/*.py whatson/
# Copy migrations here rather than map them as a volume at runtime as we must
# retain the __init__.py file and __pycache__ folder within whatson/migrations/
COPY data-admin/whatson/migrations/*.py whatson/migrations/

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
