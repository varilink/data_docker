FROM nginx
LABEL maintainer='david.williamson@varilink.co.uk'

COPY config.sh /docker-entrypoint.d/

RUN chmod +x /docker-entrypoint.d/config.sh

CMD [ "nginx-debug", "-g", "daemon off;" ]
