# Live deploymnet currently based on Debian buster
FROM debian:bookworm
LABEL maintainer='david.williamson@varilink.co.uk'

# Install required Debian APT application packages then any CPAN modules that we
# need that aren't packaged for Debian. All lib... APT packages are Perl modules
# used by this web application. The sqlite3 package isn't used by this web
# application but we use it to create a test admin user in the
# docker-entrypoint.sh script.
RUN                                                                            \
  apt-get update                                                            && \
  apt-get install --no-install-recommends --yes                                \
    build-essential                                                            \
    cpanminus                                                                  \
    exim4-daemon-light                                                         \
    gosu                                                                       \
    htmldoc                                                                    \
    libcanary-stability-perl                                                   \
    libcgi-application-dispatch-perl                                           \
    libcgi-application-plugin-anytemplate-perl                                 \
    libcgi-pm-perl                                                             \
    libcgi-psgi-perl                                                           \
    libclass-xsaccessor-perl                                                   \
    libclone-perl                                                              \
    libcommon-sense-perl                                                       \
    libconfig-any-perl                                                         \
   	libconfig-general-perl                                                     \
   	libdata-formvalidator-constraints-datetime-perl                            \
    libdatetime-perl                                                           \
    libdbd-sqlite3-perl                                                        \
    libdevel-checkbin-perl                                                     \
    libemail-mime-perl                                                         \
    libextutils-config-perl                                                    \
    libextutils-helpers-perl                                                   \
    libfile-homedir-perl                                                       \
    libfile-libmagic-perl                                                      \
    libfont-ttf-perl                                                           \
    libfurl-perl                                                               \
    libhash-case-perl                                                          \
    libhash-merge-perl                                                         \
    libjson-perl                                                               \
   	liblist-allutils-perl                                                      \
   	libmath-random-isaac-xs-perl                                               \
    libmath-random-secure-perl                                                 \
   	libmime-base64-urlsafe-perl                                                \
   	libmodule-build-tiny-perl                                                  \
    libmoo-perl                                                                \
   	libmoox-types-mooselike-perl                                               \
    libplack-perl                                                              \
    libstring-random-perl                                                      \
    libsub-uplevel-perl                                                        \
    libsys-hostname-long-perl                                                  \
   	libtemplate-perl                                                           \
   	libtest-deep-perl                                                          \
    libtest-exception-perl                                                     \
   	libtest-fatal-perl                                                         \
    libtest-leaktrace-perl                                                     \
    libtest-memory-cycle-perl                                                  \
    libtest-mockobject-perl                                                    \
    libtest-needs-perl                                                         \
   	libtest-requires-perl                                                      \
   	libtest-warnings-perl                                                      \
   	libtypes-serialiser-perl                                                   \
    liburi-perl                                                                \
   	libyaml-perl                                                               \
    mailutils                                                                  \
    sqlite3                                                                    \
    uwsgi                                                                      \
    uwsgi-plugin-psgi                                                       && \
  cpanm                                                                        \
    Config::Context                                                            \
    Data::Recursive::Encode                                                    \
    Ref::Util::XS                                                              \
    Test::AllModules                                                           \
    Test::DiagINC                                                              \
    Test::Mock::Furl                                                        && \
  cpanm                                                                        \
    App::Genpass                                                               \
    CGI::Application::Plugin::Config::Context                                  \
    Data::FormValidator::Constraints::MethodsFactory                           \
    Data::Password::Check                                                      \
    Facebook::OpenGraph                                                        \
    HTML::HTMLDoc                                                              \
    JSON::XS                                                                   \
    List::MoreUtils                                                            \
    List::SomeUtils::XS                                                        \
    Mo                                                                         \
    Mozilla::CA                                                                \
    Package::Stash::XS                                                         \
    PDF::API2                                                                  \
    Ref::Util                                                                  \
    Type::Tiny::XS

RUN                                                                            \
  apt-get --yes --no-install-recommends install                                \
    dovecot-imapd                                                              \
    whois                                                                   && \
  sed -i 's/^#disable_plaintext_auth = yes$/disable_plaintext_auth = no/'      \
    /etc/dovecot/conf.d/10-auth.conf                                        && \
  useradd --create-home username                                               \
    --password `mkpasswd --method=md5 userpasswd`                           && \
  mkdir /cookies                                                            && \
  chown www-data:www-data /cookies

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
