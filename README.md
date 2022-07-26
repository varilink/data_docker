# DATA - Docker

David Williamson @ Varilink Computing Ltd

------

Docker Compose services for development and testing of the Derby Arts and Theatre Association (DATA) website on the desktop.

## Web Service Layer Build

1. Create `web/data-web/node_modules` folder
2. Install project dependencies using this command:

```bash
docker-compose run --rm npm install --save-dev
```

3. Create `web/data-web/dist` folder
4. Build the assets for distibution using this command:

```bash
docker-compose run --rm --user '1000:1000' npm run build
```
Substitue `1000:1000` for your own client UID and GID if they're different. This is so that the built asset files have the correct ownership on the host. If you don't include this then the asset files are written to the host with `root:root` ownership.

I don't know why this is necessary for the build step but not for the install step. The install step populates `node_modules` inheriting the ownership of that folder. Something to investigate further when time allows.

Note that because of this the build will output the message `npm update check failed`. This can be safely ignored.