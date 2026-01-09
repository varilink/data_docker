# NOTE: Latest image version used and not version to match nginx in live
# The nginx official Docker image supports the use of environment variables in
# the nginx configuration, which I use in this repository - see
# https://hub.docker.com/_/nginx. However this features is new in version 1.19
# of the Docker image and the nginx version currently in use in live is 1.10.3,
# so I'm not matching the live version here.
FROM nginx
LABEL maintainer='david.williamson@varilink.co.uk'

COPY config.sh /docker-entrypoint.d/

RUN                                                                            \
  chmod +x /docker-entrypoint.d/config.sh

CMD [ "nginx-debug", "-g", "daemon off;" ]
