This is the configuration folder for the DATA web application when it is running in a container environment facilitated by this repository. Since the configuration is implemented using multiple files, thie README exists to explain the structure.

| File/Directory | Category of Configuration                                                                                          |
| -------------- | ------------------------------------------------------------------------------------------------------------------ |
| app/           | Inherent within the DATA web application and are therefore included from the [DATA - App] repository.              |
| int/           | Relating to third-party integrations that contains senstive information and is included from a private repository. |
| common.cfg     | Common to all environment configurations implemented by this repositoty.                                           |
| env.cfg        | Main environment configuration, which integrates with test third-party service.                                    |
| live-int.cfg   | Environment configuration that integrates with live third-party services for running production commands.          |