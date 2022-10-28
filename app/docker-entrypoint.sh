#!/usr/bin/env bash

set -e # exit immediately if a command exits with a non-zero status

if [[ ! -f /database/derbyartsandtheatre.db ]]
then

  # Copy to application from the backup
  cp /backup/derbyartsandtheatre.db /database/
  chown www-data:www-data /database/derbyartsandtheatre.db

  # Set every user's password to "password" for testing purposes
	sqlite3 /database/derbyartsandtheatre.db <<- EOF
	UPDATE user
		SET password = '5f4dcc3b5aa765d61d8327deb882cf99'
	EOF

fi

dovecot

exec uwsgi "$@"
