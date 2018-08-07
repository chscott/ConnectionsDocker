## DB2 for Connections container

Containers created from the [DB2 for Connections image](..\images\db2_ic.md) contain a DB2 instance that is fully configured
for Connections. Containers perform a short initialization that creates the instance, performs environment configuration, and
ensures the Connections databases are created. Run-time options allow databases to be created or upgraded to specific 
Cumulative Refresh levels.

While the container is designed to be ephemeral, the container's data must be persistent. This is achieved by using a named 
volume at run time. This volume exists as a directory on the Docker host system, which allows it to be backed up by standard
backup tooling. If no volume is specified or the specified volume is new, Connections databases will be created from scratch.

### Syntax

```
$ docker run --name CONTAINER_NAME --privileged --volume VOLUME_NAME:/data --publish 50000:50000 --env-file ENV_FILE -d IMAGE_NAME
```

### Options

- **--name**: A user-friendly name for the container.

- **--privileged**: DB2 performs certain operations that require elevated privileges.

- **--volume**: Mounts the named volume at /data, which is where the instance is installed.

- **--publish**: Exposes the identified port on the host system.

- **--env-file**: Exports the environment variables from the named file. The supported environment variables are:
                
    - DB_WIZARDS_URL (internal location of the database wizards package)
    - CR1_UPDATE_URL (internal location of the CR1 database update package)
    - CR2_UPDATE_URL (internal location of the CR2 database update package)
                
The environment variables set via --env-file depend on the current state of the volume. An example file can be downloaded
from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/env-db2.txt

```
$ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/env-db2.txt
```

If the databases have not been created (i.e. the volume is new), then DB_WIZARDS_URL is required so the databases can be 
created. In that state, both CR1_UPDATE_URL and CR2_UPDATE_URL are optional. If provided, the most recent CR updates will be 
applied to the databases.

If the databases have already been created, the DB_WIZARDS_URL variable has no effect. The CR1_UPDATE_URL and CR2_UPDATE_URL
work as described in the preceding paragraph. If the updates have already been applied, no changes will be made.

### Signals

The DB2 for Connections container reacts to the following signals, which can be passed via the docker kill command.

```
$ docker kill --signal SIGNAL_NAME
```

- **SIGTERM**: Stop DB2 and exit the container

- **SIGINT**: Stop DB2 and exit the container

- **SIGHUP**: Restart DB2

### Example

This example starts a new container named db2_ic from the [db2/11.1.1/ic image](../images/db2_ic.md), exposes port 50000 on
the host system, and mounts the volume named db2_ic at /data. Note that this volume does not need to exist before running the
command. Databases will be created at CR2 level since CR2_UPDATE_URL is set in env.txt.

```
$ docker run --name db2_ic --privileged --volume db2_ic:/data --publish 50000:50000 --env-file env-db2.txt -d db2/11.1.1/ic

$ cat env-db2.txt
# Internal location of Connections database wizard package
DB_WIZARDS_URL=ftp://FTP_SERVER/FTP_DIRECTORY/Connections_6.0_Wizards_lin_aix.tar
# Internal location of CR1 update package
# CR1_UPDATE_URL=ftp://FTP_SERVER/FTP_DIRECTORY/60cr1-database-updates_20171128.zip
# Internal location of CR2 update package
CR2_UPDATE_URL=ftp://FTP_SERVER/FTP_DIRECTORY/60cr2-database-updates.zip
```