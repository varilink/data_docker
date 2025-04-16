The volumes directive in the `docker-compose.yml` file for this repository contains the following lines:

```yaml
# Application configuration files
- ./app/conf/:/usr/local/etc/
- ./app/data_app/conf/:/usr/local/etc/app/:ro
- ./data_int:/usr/local/etc/int/:ro
```

If the directories `./app/conf/app/` and `.app/conf/int/` don't already exist on the Docker host, then they will be created by the root user. This directory exists in order to prevent this happening.
