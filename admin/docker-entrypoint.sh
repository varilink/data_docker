#!/usr/bin/env bash

set -e # exit immediately if a command exits with a non-zero status

if [[ -f /data/db.sqlite3 ]]
then

  mv /data/db.sqlite3 /database/core.db
  chown www-data:www-data /database/core.db

fi

rsync -avu --delete                                                            \
  /usr/local/lib/python3.7/dist-packages/django/contrib/admin/static/          \
  /static/

exec uwsgi "$@"
