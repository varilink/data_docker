# ------------------------------------------------------------------------------
# app/Dockerfile
# ------------------------------------------------------------------------------

# Dockerfile for building this project's Docker Compose app service.

# ------

FROM debian:bookworm AS pl
LABEL maintainer='david.williamson@varilink.co.uk'

# Copy:
#   1. The lists of packages used by the web application, see the README within
#      the packages/ directory.
#   2. The Perl script that converts those lists from YAML format into a space
#      separated string, suitable as command line arguments.

COPY data_app/packages/ /packages/
COPY yaml-to-string.pl /

# Install required Debian APT application packages then any CPAN modules that we
# need that aren't packaged for Debian. All lib... APT packages are Perl modules
# used by this web application. The sqlite3 APT package isn't used by this web
# application but we use it to create a test admin user in the
# docker-entrypoint.sh script. We also need to bring forward the install of the
# libyaml-perl APT package as the yaml-to-string.pl script uses it.

RUN                                                                            \
  apt-get update                                                            && \
  apt-get install --no-install-recommends --yes                                \
    libyaml-perl                                                               \
    sqlite3                                                                 && \
  apt-get install --no-install-recommends --yes                                \
    `perl /yaml-to-string.pl deb`                                           && \
  cpanm --notest                                                               \
    `perl /yaml-to-string.pl cpan1`                                         && \
  cpanm --notest                                                               \
    `perl /yaml-to-string.pl cpan2`

FROM pl AS full

# We install dovecot-imapd for easy access to emails within the container
# environment and the whois package provides the mkpasswd command that we then
# use to create the user account we're going to use to access those emails.

# Commands that are required within this container environment but are not part
# of implementing the core web application. These implement the following steps:
#   1. Preconfigure the Roundcube implementation.
#   2. Install the APT packages required to implement Dovecot and Roundcube for
#      easy access from the Docker host to emails within this service.
#   3. Post install configuration of Dovecot and Roundcube.
#   4. Install of further APT packages that are required in this container
#      environment only.
#   5. Creation of the user that we're going to use to receive emails.
#   6. Setup the /cookies directory, including giving it the correct ownership.

RUN                                                                            \
  echo "roundcube-core roundcube/dbconfig-install boolean true"                \
    | debconf-set-selections                                                && \
  echo "roundcube-core roundcube/database-type select sqlite3"                 \
    | debconf-set-selections                                                && \
  apt-get --yes --no-install-recommends install                                \
    apache2                                                                    \
    dovecot-imapd                                                              \
    gosu                                                                       \
    python3                                                                    \
    python3-venv                                                               \
    roundcube                                                                  \
    roundcube-core                                                             \
    roundcube-sqlite3                                                          \
    whois                                                                   && \
  sed -i 's/^#disable_plaintext_auth = yes$/disable_plaintext_auth = no/'      \
    /etc/dovecot/conf.d/10-auth.conf                                        && \
  sed -i 's/^#[ \t]*Alias/Alias/'                                              \
    /etc/apache2/conf-available/roundcube.conf                              && \
  useradd --create-home username                                               \
    --password `mkpasswd --method=md5 userpasswd`                           && \
  mkdir /cookies                                                            && \
  chown www-data:www-data /cookies                                          && \
  python3 -m venv /root/.venv

RUN bash -c "                                                                  \
  source ~/.venv/bin/activate                                               && \
  pip install wheel                                                         && \
  pip install uwsgitop"

# Setup the entrypoint.

COPY docker-entrypoint.sh /
ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]
