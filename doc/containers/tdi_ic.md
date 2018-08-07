## TDI for Connections container

Containers created from the [TDI for Connections image](..\images\tdi_ic.md) contain a TDI solution that is fully configured
for Connections. Containers perform a short initialization that configures the solution and then are ready for use.

While the container is designed to be ephemeral, the container's data must be persistent. This is achieved by using a named 
volume at run time. This volume exists as a directory on the Docker host system, which allows it to be backed up by standard
backup tooling.

### Syntax

```
$ docker run --name CONTAINER_NAME --volume VOLUME_NAME:/data --link <DB2_CONTAINER>:db2 --env-file ENV_FILE -d IMAGE_NAME
```

### Options

- **--name**: A user-friendly name for the container.

- **--volume**: Mounts the named volume at /data, which is where the solution directory is installed.

- **--link**: Links the TDI container to a DB2 container, enabling inter-container communication.

- **--env-file**: Exports the environment variables from the named file. The supported environment variables are:

    - **TDISOL_URL**

      The internal download location of your TDI solution directory for Connections.

    - **LDAP_TYPE**

      The type of your LDAP system. Supported options are:

      - AD (Microsoft Active Directory)
      - DOMINO (IBM Domino)
      - DSEE (Oracle Directory Server Enterprise Edition)
      - SDS (IBM Security Directory Server)

    - **LDAP_HOST**

      The FQDN of your LDAP server.

    - **LDAP_PORT**

      The port used for LDAP communication (typically 389 or 636).

    - **LDAP_BIND_DN**

      The distinguished name used to bind to LDAP.
      Example, LDAP_BIND_DN=cn=ldapbind,ou=ic,dc=ad,dc=com

    - **LDAP_BIND_PWD**

      The password for the distinguished name used to bind to LDAP.

    - **LDAP_SEARCH_BASE**

      The search base used for locating users and groups in LDAP.
      Example: LDAP_SEARCH_BASE=ou=ic,dc=ad,dc=com

    - **LDAP_SEARCH_FILTER**

      The search filter used for locating users in LDAP. Note that special characters like '&' must be escaped with a backslash (\) character.
      Example: LDAP_SEARCH_FILTER=(\&(uid=*)(objectClass=inetOrgPerson))

    - **DB2_HOST**

      The FQDN or container alias of your DB2 server. Use the FQDN if DB2 is installed on a non-containerized OS. If DB2
      is running inside a container, use the container alias used in the --link option.

    - **DB2_PORT**

      The port used for DB2 communication (typically 50000).

    - **DB2_PROFILES_USER**

      The user account that owns the profiles database (default is lcuser).

    - **DB2_PROFILES_PWD**

      The password for the user account that owns the profiles database.          
                
An example file can be downloaded from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/env-tdi.txt.

```
$ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/env-tdi.txt
```

### Signals

The TDI for Connections container reacts to the following signals, which can be passed via the docker kill command.

```
$ docker kill --signal SIGNAL_NAME
```

- **SIGTERM**: Exit the container

- **SIGINT**: Exit the container

- **SIGUSR1**: Synchronize users

### Example

This example starts a new container named tdi_ic from the [tdi/7.1.1.6/ic image](../images/tdi_ic.md) and mounts the volume 
named tdi_ic at /data. Note that this volume does not need to exist before running the command. Additionally, the container
will be linked to another container named db2_ic, which is mapped to the alias db2. This allows the TDI container to
communicate with the DB2 container for user synchronization.

```
$ docker run --name tdi_ic --volume tdi_ic:/data --link db2_ic:db2 --env-file env-tdi.txt -d tdi/7.1.1.6/ic

$ cat env-tdi.txt
# Internal download location for the TDI solution directory for Connections
TDISOL_URL=ftp://FTP_SERVER/FTP_DIRECTORY/TDISOL_PACKAGE

# LDAP type: AD (Active Directory), DOMINO, DSEE (Oracle Directory Server Enterprise Edition) or SDS (IBM Security Directory Server)
# Example: LDAP_TYPE=AD
LDAP_TYPE=AD

# FQDN of the LDAP host system
# Example: LDAP_HOST=ldap.example.com
LDAP_HOST=ldap.example.com

# Port used to contact LDAP (usually 389 or 636)
LDAP_PORT=389

# Bind DN used to connect to LDAP. 
# Example: LDAP_BIND_DN=cn=ldapbind,ou=ic,dc=ad,dc=com
LDAP_BIND_DN=cn=ldapbind,ou=ic,dc=ad,dc=com

# Password for the LDAP bind DN account
LDAP_BIND_PWD=password

# Search base for locating users to populate into Connections. 
# Example: LDAP_SEARCH_BASE=ou=ic,dc=ad,dc=com
LDAP_SEARCH_BASE=ou=ic,dc=ad,dc=com

# Search filter for locating users to populate into Connections. Note that special characters like '&' must be escaped.
# Example: LDAP_SEARCH_FILTER=(\&(uid=*)(objectClass=inetOrgPerson))
LDAP_SEARCH_FILTER=(\&(uid=*)(objectClass=inetOrgPerson))

# FQDN or container link name/alias of the DB2 host system
# Use FQDN if DB2 runs inside a non-containerized operating system
# Use the container link name or alias if DB2 runs inside another Docker container
DB2_HOST=db2

# Port used to contact DB2 (usually 50000)
DB2_PORT=50000

# User account that owns the profiles database (default is lcuser)
DB2_PROFILES_USER=lcuser

# Password for the user account that owns the profiles database
DB2_PROFILES_PWD=password
```