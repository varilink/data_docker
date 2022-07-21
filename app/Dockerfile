# Live deploymnet currently based on Debian buster
FROM debian:buster
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
    htmldoc                                                                    \
    uwsgi                                                                      \
    uwsgi-plugin-psgi                                                          \
    libcgi-application-dispatch-perl                                           \
    libcgi-application-plugin-anytemplate-perl                                 \
    libcgi-psgi-perl                                                           \
    libclass-xsaccessor-perl                                                   \
    libclone-perl                                                              \
    libconfig-any-perl                                                         \
   	libconfig-general-perl                                                     \
   	libdata-formvalidator-constraints-datetime-perl                            \
    libdatetime-perl                                                           \
    libdbd-sqlite3-perl                                                        \
   	libemail-mime-perl                                                         \
   	libextutils-config-perl                                                    \
   	libextutils-helpers-perl                                                   \
   	libfile-homedir-perl                                                       \
   	libfile-libmagic-perl                                                      \
    libhash-case-perl                                                          \
    libhash-merge-perl                                                         \
    libjson-perl                                                               \
   	liblist-allutils-perl                                                      \
   	libmath-random-isaac-xs-perl                                               \
    libmath-random-secure-perl                                                 \
   	libmodule-build-tiny-perl                                                  \
    libmoo-perl                                                                \
   	libmoox-types-mooselike-perl                                               \
    libplack-perl                                                              \
    libstring-random-perl                                                      \
    libsys-hostname-long-perl                                                  \
   	libtemplate-perl                                                           \
   	libtest-deep-perl                                                          \
   	libtest-fatal-perl                                                         \
    libtest-leaktrace-perl                                                     \
   	libtest-requires-perl                                                      \
   	libtest-warnings-perl                                                      \
   	libyaml-perl                                                               \
    sqlite3                                                                 && \
  cpanm                                                                        \
    App::Genpass                                                               \
    CGI::Application::Plugin::Config::Context                                  \
    Data::FormValidator::Constraints::MethodsFactory                           \
    Data::Password::Check                                                      \
    HTML::HTMLDoc                                                              \
    JSON::XS                                                                   \
    List::SomeUtils::XS                                                        \
    Mo                                                                         \
    Package::Stash::XS                                                         \
    Ref::Util                                                                  \
    Type::Tiny::XS

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
