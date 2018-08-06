## TDI for Connections image

In this guide, we'll walk through creating a Docker TDI image for Connections. This image inherits the installed TDI server
via the [TDI base image](tdi_base.md) and adds additional run-time artifacts to create a solution directory for use with 
Connections. All configuration steps from the documentation are performed automatically.

This image is intended to create a turn-key solution. Containers started from this image perform a short initialization and
are then ready to use with Connections.

### Prerequisite

Create the [TDI base image](tdi_base.md).

### Steps

1. On the Docker host system, create a directory to hold the image artifacts. For this guide, we'll use ~/images/tdi/ic.

2. Change to the ~/images/tdi/ic directory.

3. Download env.txt from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/env.txt.
   
   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/env.txt
   ```
 
4. Open env.txt and update the variables for your environment:

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
     
     The distinguished name used to bind to LDAP. For example, LDAP_BIND_DN=cn=ldapbind,ou=ic,dc=ad,dc=com.
   
   - **LDAP_BIND_PWD**
     
     The password for the distinguished name used to bind to LDAP.
   
   - **LDAP_SEARCH_BASE**
     
     The search base used for locating users and groups in LDAP. For example, LDAP_SEARCH_BASE=ou=ic,dc=ad,dc=com.
   
   - **LDAP_SEARCH_FILTER**
     
     The search filter used for locating users in LDAP. Note that special characters like '&' must be escaped with a backslash (\) character. For example: LDAP_SEARCH_FILTER=(\&(uid=*)(objectClass=inetOrgPerson)).
   
   - **DB2_HOST**
     
     The FQDN of your DB2 server.
   
   - **DB2_PORT**
     
     The port used for DB2 communication (typically 50000).
   
   - **DB2_PROFILES_USER**
     
     The user account that owns the profiles database (default is lcuser).
   
   - **DB2_PROFILES_PWD**
     
     The password for the user account that owns the profiles database.
   
5. Create the ~/images/tdi/ic/image directory.

6. Change to the ~/images/tdi/ic/image directory.
   
7. Copy the Dockerfile from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/Dockerfile. 

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/Dockerfile
   ```  
   
8. Create the ~/images/tdi/ic/image/setup directory.
   
9. Change to the ~/images/tdi/ic/image/setup directory.
   
10. Download entrypoint.sh from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/entrypoint.sh.

    ```
    $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/entrypoint.sh
    ```

11. Make the entrypoint.sh script executable.

    ```
    $ chmod u+x entrypoint.sh
    ```
   
12. At this point, you should have the following directories/files:

    - ~/images/tdi/ic/env.txt
    - ~/images/tdi/ic/image/Dockerfile
    - ~/images/tdi/ic/image/setup/entrypoint.sh
   
13. Change to the ~/images/tdi/ic/image directory.

14. Build the image.

    ```
    $ docker build -t tdi/7.1.1.6/ic .
    ```
    
15. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
You have now successfully created the TDI for Connections image. For next steps, review the documentation for running a 
[TDI for Connections container](../containers/tdi_ic.md).