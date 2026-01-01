The volumes directive for the *app* service in the `docker-compose.yml` file for this repository contains the following lines:

```yaml
# Configuration
- &vol-env-conf "./app/conf/:/usr/local/etc/"
- &vol-app-conf "./app/data_app/conf/:/usr/local/etc/app/:ro"
- &vol-int-conf "./data_int:/usr/local/etc/int/:ro"
```

If the directories `./app/conf/app/` and `.app/conf/int/` don't already exist on the Docker host, then they will be created by the root user. This directory exists in order to prevent this happening.
