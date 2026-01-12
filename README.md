# DATA - Docker

David Williamson @ Varilink Computing Ltd

------

Docker Compose services for the *build* and *test* on the developer desktop of:

- The Derby Arts and Theatre Association (DATA) web application
- CLI script commands associated with the DATA web application
- The Django admin interface that facilitates editing of the DATA web applicaton's database

This repository also provides the facility for *live* use of the web application's social media integration functionality.

## Contents

| Files and Directories                                          | Contents                                                                                                                                                                                                                                                  |
| -------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `.env`<br>`docker-compose.yml`                                 | Project Docker Compose setup for services ("up") and tools ("run").                                                                                                                                                                                       |
| `admin-app/`<br>`admin-web`<br>`app/`<br>`web/`                | Content for each of the services that combine to deliver the DATA web applicatoin and Django admin interface.                                                                                                                                             |
| `backup/`                                                      | Directory that can hold backup files from an instance of the website to restore from locally.                                                                                                                                                             |
| `data-int/`                                                    | The private "DATA - Int" repo, included here as a submodule, which contains private data used for the DATA integrations with Facebook, Mailchimp, X (formerly Twitter) and YouTube.                                                                       |
| `inputs/`<br>`outputs/`                                        | Directories to hold inputs and outputs for commands provided by this repository.                                                                                                                                                                          |
| `tools/contacts/`<br>`tools/pod2markdown/`<br>`tools/uwsgitop` | Tools specific to this project and therefore defined entirely within this repository.                                                                                                                                                                     |
| `tools/gimp/`<br>`tools/npm/`<br>`tools/proxy/`                | Tools provided by Varilink [Tools - GIMP](https://github.com/varilink/tools-gimp), [Tools - NPM](https://github.com/varilink/tools-npm) and [Tools - Proxy](https://github.com/varilink/tools-proxy) repositories, which are used here as Git submodules. |
| `wordpress/`                                                   | Dummy folder to avoid the Varilink [Tools - GIMP](https://github.com/varilink/tools-gimp) tool creating it and it therefore being owned by the root user.                                                                                                 |

## Usage

The notes that follow on how to use this repository are separated into the three aspects highlighted above:

1. Build
2. Test
3. Live

### Build

Docker Compose commands that build various artefacts used by this project repository.

#### Web Service Assets

The `web/data-web/dist` directory contains client-side *assets* (by type in `css`, `docs`, `img`, `js` and `webfonts` subdirectories). These are built from source files in three steps:

1. Install NPM dependencies:

```sh
docker-compose run --rm npm install --save-dev
```

We use the `--save-dev` option to install packages that are used in the subsequent build steps but not by the live web application. This command populates the `web/data_web/node_modules/` directory.

2. Generate media files:

```sh
docker-compose run --rm gimp
```

This command populates the `web/data_web/media/other` and `web/data_web/media/website` directories. The first of these contains images that are used by the DATA application's web service. The second contains images for uploading to the DATA social media profiles.

3. Run the project's *webpack* build script:

```sh
docker-compose run --rm npm run build
```

Uses the contents of the `web/data_web/src/` and `web/data_web/media/website/` directories to populate the `web/data_web/dist` directory, which then contains all of the client side assets (`css`, `docs`, `img`, `js` and `webfonts` subdirectories) that are used by the DATA application's web service.

#### Perl Documentation

The application contains three types of artefacts written in Perl:

1. Perl scripts (`app/data-app/pl/`)
2. Web application modules that use the `CGI::Application` framework (`app/data-app/pm/`)
3. PSGI scripts (`app/data-app/psgi/`)

All three contain inline documentation written in the Perl Plain Old Documentation (POD) format. The facility is provided to output this documentation as markdown in README files for convenient reading on GitHub.

The command:

```sh
docker-compose run --rm pod2markdown
```

Will refresh the contents of `app/data-app/pod2markdown/` with markdown formatted POD generated from the source code in `app/data-app/pl/`, `app/data-app/pm/` and `app/data-app/psgi/`. thus providing Perl code documentation in the [DATA - App](https://github.com/varilink/data-app) repository on GitHub.

### Test

This repository provides the ability to bring up test instances of the DATA website and its associated Django admin interface and access them with a web browser, all on the developer desktop.

#### DATA website

##### Restore from Backup

The data for testing the website on the developer desktop can be based on a backup taken from the live or a test instance of the website. Such backups can be obtained using the `backup.yml` Ansible playbook from within the [DATA - Ansible](https://github.com/varilink/data_ansible) repository.

You must copy both the `derbyartsandtheatre.db` SQLite database and the `upload/` directory, which contains uploaded event images, from the backup into the `backup/` directory within this repository. It's not necessary to include the `core.db` SQLite database, which is also present in live or test instances of the website, as this is rebuilt from scratch during container startup.

To trigger the restore from these backup files, you must remove the `data_database` and `data_upload` volumes. The *app* service when it is brought up will restore the `derbyartsandtheatre.db` database from the `backup/` to the `data_database` volume when it detects that it is not already present. The *web* service will do the same in respect of the `upload/` directory and the `data_upload` volume.

In order to remove the `data_database` and `data_upload` volumes it is necessary to first stop and remove any containers that reference them. The following command should do the job:

```sh
docker-compose stop && docker-compose rm && docker volume rm data_database data_upload
```

##### Bring up the website

To bring up the website:

```sh
docker-compose --profile data up
```

The option `--profile data` brings up the *web*, *app* and *proxy* services, which together implement the DATA website on the developer desktop.

The website will then be accessible from the developer desktop at [http://data](http://data) if you configure a web browser correctly to access the *proxy* service via the *localhost* interface - see the [README in the Varilink "Tools - Proxy" repo](https://github.com/varilink/tools-proxy#readme) for details of how to do this. This repository is configured to expose the *proxy* service on port 3133 of the localhost interface but you can change this if required by changing the value of the `PROXY_PORT` variable in the `.env` file.

#### Environment specific web application characteristics

The DATA web application has some environment specific characteristics in the container environment that is created by this repository that it's important to mention here.

- reCAPTCHA integration is disabled in this environment.

- The social media integrations are all by default with the test services that are described in the "DATA - Int", private repository.

- The restore from backup overrides the passwords of all web application user accounts to *password*. A list of those user accounts can be obtained by running the following command:

```sh
docker-compose exec -T app bash <<EOF
sqlite3 /var/www/app/database/derbyartsandtheatre.db
SELECT userid,role,status FROM user;
EOF
```

- All emails generated by the web application are sent to the email address *username@localhost*, which corresponds to the mailbox for the user *username* within the *app* service. That service hosts an IMAP server service, which is mapped to port 143 on the host. Thus, those emails can be viewed in an email client on the host, at *localhost:143* using username *username* and password *userpasswd*.

    Furthermore the *app* service implements a webmail service that is exposed to the user desktop via the *proxy* service. So a web browser on the user desktop that is configured with the proxy settings required by the [Tools - Proxy](https://github.com/varilink/tools_proxy) repository can also read those emails. Those settings are the same as those required to access the *web* service from the user desktop.

    To access this webmail service, the following URL and user credentials must be used.

    URL: http://webmail/roundcube<br>
    User Name: username<br>
    User Password: userpasswd

- You can increase the level of logging in the *web* and *app* services in order to help in diagnosing issues. In both services, this is controllable by the setting of environment variables.

    *web*

    This is a reverse proxy server based on Nginx and exposes the ability to enable [Setting Up the Error Log](https://docs.nginx.com/nginx/admin-guide/monitoring/logging/) using the `DATA_WEB_ERROR_LOG_LEVEL` environment variable. If you set this then the `error_log` configuration setting will be set, with the error log file path `/var/log/nginx/error.log` within the container and a logging level set to whatever you set the environment variable to from the valid Nginx options of `debug`, `info`, `notice`, `warn`, `error`, `crit`, `alert` and `emerg`.

    For the change to take effect, it's necessary to rebuild the container, so for example you can do this:

    ````sh
    docker-compose stop web && docker-compose rm web && DATA_WEB_ERROR_LOG_LEVEL=info docker-compose up web
    ````

    *app*

    The [Logging and Debugging](https://github.com/varilink/data_app#logging-and-debugging) section in the README for the [DATA - App](https://github.com/varilink/data_app) repository describes the facility for logging and debugging that's builtin to the *app* service.

#### Django Admin Interface

The DATA website implements a secure, admin area for updating the DATA database. In addition to that, as described above, this repository also implements a Django admin interface that can be used to perform CRUD operations on the DATA database.

To bring up the Django admin interface run this command:

```sh
docker-compose --profile admin up
```

Note that since it is *app* service that restores the `derbysartsandtheatre.db` service to the `data_database` volume, you must have brought this service up following the instructions for the [DATA website](#data-website) above **before** you bring up the Django admin interface, otherwise it won't be able to access an instance of the DATA database.

The Django admin interface can be accessed using a web browser on the developer desktop in exactly the same way as you can the DATA website, except that the URL to use is [http://admin](http://admin). The build process for the *admin-app* service creates a Django superuser with the username *testuser* and the password *testpass* that you can use to login to the admin interface.

##### Publishing a News Item

The website shows blog posts as news items. These are published using Django's migrations facility to propagate changes to its database schema. The process for publishing a news item is detailed in the master README for the [DATA - Admin](https://github.com/varilink/data_admin) repository. In the container environment created by this repository, the following additional notes apply:

- The path to the `migrations` folder relative to this repository's root folder is `admin-app/data_admin/whatson/migrations/`.

- Deployment of new migration files equates to copying them into the running container created by the `admin-app` service.

- The folder that they must be copied to in that container is `/var/www/admin-app/django/whatson/smigrations/`.

- The migration files are copied into the `varilink/data/admin-app` image as part of build process rather than map the `admin-app/data_admin/whatson/migrations/` directory in this repository using a `volumes` directive for the `admin-app` service so as not to clobber the `__init__.py` and `__pychache__` files. So, if you add new migration files then you should rebuild that image. You can of course use `docker cp` beforehand while trialling new migrations.

- If you run `docker-compose exec admin-app bash` from the host then you will be in that container in the `/var/www/admin-app/django/` directory with root privileges and so may proceed directly to run the migrate command.

- You can test a new migration multiple times, changing it in-between tests, by removing the `data_database` volume between each test - see above under [Restore from backup](#restore-from-backup). This allows you to rehearse and refine a migration using containers before applying it to the live website.

##### The django-static Volume

Apart from the `data_database` and `data_upload` named volumes referred to earlier this repository defines one more named volume, which is named `data_django-static`. This volume's purpose is to enable the sharing of the static client web assets of the Django admin site between the `admin-web` and `admin-app` services.

The `admin-app` service uses the Django admin's `collectstatic` script to populate this named volume every time it starts up and if necessary to refresh it with any updates between versions. The `admin-web` service then takes all its static client web assets from the same named volume.

In theory I don't think there should ever be a need to delete this volume but should any issue arise with its contents then you can of course force it to be repopulated from empty the next time that the `admin-app` service starts up by using the command:

```sh
docker-compose volume rm data_django-static
```

Of course you would need to ensure that any containers associated with `admin-web` and `admin-app` services are stopped and removed beforehand.

#### The pl Docker Compose Service

This repository implements a `pl` Docker Compose service that enables you to run any Perl Script from the [DATA - App](https://github.com/varilink/data_app) repository using this command:

```sh
docker-compose run --rm pl <SCRIPT> [<OPTIONS>...]
```

Where `<SCRIPT>` is the name of the script, including its `.pl` extension, which must be one of [DATA - App repository's Perl scripts](https://github.com/varilink/data_app/tree/main/pl) and `<OPTIONS>` is a list of zero or more options for the script, which of course is script specific.

##### Live social media integration

By default, when you run Perl scripts using the Docker Compose `pl` service as described above, those scripts will access:

1. The local `derbysartsandtheatre.db` SQLite database that has been restored from backup by the `app` service.

2. The local `upload` images directory that has been restored from backup by the `web` service.

3. Test versions of the DATA Facebook, Mailchimp and X social media integrations.

That is of course if the script accesses one or both of those, some don't. The test versions of the DATA Facebook, Mailchimp and X social media integrations are differentiated from their live counterparts as follows:

| Platform  | Test Version                                                              |
| --------- | ------------------------------------------------------------------------- |
| Facebook  | Uses a private, Facebook page rather than the public, live Facebook page. |
| Mailchimp | Uses a test audience rather than the live audience.                       |
| X         | Uses a private, test X account rather than the public, live X account.    |

This repository provides the ability to switch to a live mode in which the social media integration configuration points to the live DATA social media profiles rather than theses test ones. This facility is intended to be used principally to create Mailchimp campaigns directly from this repository. If the campaign to be created includes either events or news items, both of which are sourced from the DATA database, then first it's necessary to update the contents of the `backup/` directory with the current `derbyartsandtheatre.db` SQLite database and the `upload/` images directory.

Having done that, you can create a Mailchimp bulletin as follows:

```sh
DATA_APP_CONF_FILE=live-int.cfg docker-compose run --rm pl mailchimp-bulletin.pl [ARG...]
```

You can display the help for the command via the container environment as follows:

```sh
docker-compose run --rm pl mailchimp-bulletin.pl -h
```

The directory `inputs/` on the host is mapped to `/inputs/` within the `pl` service container so that you can place HTML inserts into it.
