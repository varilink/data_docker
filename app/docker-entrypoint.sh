# ------------------------------------------------------------------------------
# app/docker-entrypoint.sh
# ------------------------------------------------------------------------------

# Entrypoint script for this project's Docker Compose app service.

# ------

set -e # exit immediately if a command exits with a non-zero status

if [[                                                                          \
  -f /database/derbyartsandtheatre.db && -s /database/derbyartsandtheatre.db   \
]]
then

  # The web application's database exists and it not zero size. The zero size
  # check is important because the admin service can create the web
  # application's database file but with a zero size as a side effect of what it
  # does to create the Django core database.

  echo 'The app service is reusing a prexisting database'

else

  # The web application's database either doesn't exist or is of zero size and
  # so we restore it from the backup that we have been configured to use.

  echo 'The app service is restoring a database from backup'

  # Copy the web application's database from the backup.

  cp /backup/derbyartsandtheatre.db /database/
  chown www-data:www-data /database/derbyartsandtheatre.db

  # Set every user's password to "password" for our testing purposes. We
  # actually store the md5 hash of the password.

	sqlite3 /database/derbyartsandtheatre.db <<- EOF
	UPDATE user
		SET password = '5f4dcc3b5aa765d61d8327deb882cf99'
	EOF

fi

 # Start dovecot to provide email access in the container environment via the
 # Roundcube webmail client. 
dovecot
source /etc/apache2/envvars
apache2

exec gosu www-data uwsgi                                                       \
  --ini /etc/uwsgi/apps-enabled/data-app.ini                                   \
  --env DATA_APP_CONF_DIR=$DATA_APP_CONF_DIR                                   \
  --env DATA_APP_CONF_FILE=$DATA_APP_CONF_FILE                                 \
  "$@"
