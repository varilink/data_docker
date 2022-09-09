FROM debian:bullseye
LABEL maintainer='david.williamson@varilink.co.uk'

RUN                                                                            \
  apt-get update                                                            && \
  apt-get --yes --no-install-recommends install                                \
    libconfig-general-perl                                                     \
    libdbd-sqlite3-perl                                                        \
    libdbi-perl                                                                \
    libhash-case-perl                                                          \
    libmail-chimp3-perl                                                        \
    libstring-random-perl                                                   && \
  mkdir /usr/local/lib/site_perl

WORKDIR /usr/local/src/

CMD [ "perl", "./app.pl" ]
