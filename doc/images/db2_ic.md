## DB2 for Connections image

In this guide, we'll walk through creating a Docker DB2 image for Connections. This image inherits the installed DB2 server
via the [DB2 base image](db2_base.md) and adds additional run-time artifacts to create an instance for use with 
Connections. All configuration steps from the documentation are performed automatically, including the creation of 
Connections databases.

This image is intended to create a turn-key solution. Containers started from this image perform a short initialization and
are then ready to use with Connections.

### Prerequisite

Create the [DB2 base image](db2_base.md).

### Steps

1. On the Docker host system, create a directory to hold the image artifacts. For this guide, we'll use ~/images/db2/ic.

2. Change to the ~/images/db2/ic directory.
   
3. Copy the Dockerfile from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/Dockerfile. 

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/Dockerfile
   ```  
   
4. Create the ~/images/db2/ic/setup directory.
   
5. Change to the ~/images/db2/ic/setup directory.
   
6. Download entrypoint.sh from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/entrypoint.sh.

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/entrypoint.sh
   ```

7. Make the entrypoint.sh script executable.

   ```
   $ chmod u+x entrypoint.sh
   ```
   
8. At this point, you should have the following directories/files:

   - ~/images/db2/ic/Dockerfile
   - ~/images/db2/ic/setup/entrypoint.sh
   
9. Change to the ~/images/db2/ic directory.

10. Build the image.

    ```
    $ docker build -t db2/11.1.1/ic .
    ```
    
11. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
You have now successfully created the DB2 for Connections image. For next steps, review the documentation for running a 
[DB2 for Connections container](../containers/db2_ic.md).