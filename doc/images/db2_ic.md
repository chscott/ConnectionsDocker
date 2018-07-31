## DB2 for Connections image

In this guide, we'll walk through creating a Docker DB2 image for Connections. This image inherits the installed DB2 server
via the [DB2 base image](doc/images/db2_base.md) and uses additional run-time artifacts to create an instance for use with 
Connections. All configuration steps from the documentation are performed automatically, including the creation of 
Connections databases.

This image is intended to create a turn-key solution. After the container starts and performs its initialization, you are
are ready to begin using the databases for Connections.

### Steps

1. On the Docker host system, create a directory to hold the image artifacts. For example, ~/images/db2/ic.

2. Change directories to the directory created in Step 1.

3. Copy the Dockerfile from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/Dockerfile. 

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/Dockerfile
   ```
   
4. Copy env.txt from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/env.txt.
   
   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/env.txt
   ```
5. Open env.txt and update the URLs for your environment. These are the locations at which the Connections database wizard
   and CR1/CR2 update packages are hosted in your environment. Only the database wizard package is required. If you want to 
   install the Connections databases at 6.0 base release level, leave the CR1 and CR2 update URLs commented out. If you want
   to install the Connections databases at 6.0 CR1 release level, uncomment the CR1 update URL. If you want to install the 
   Connections databases at 6.0 CR2 release level, uncomment the CR2 update URL. These files will be downloaded during 
   installation.
   
6. Create a subdirectory named setup. If you used the example directory in Step 1, it will be located at 
   ~/images/db2/ic/setup.
   
7. Change directories to the setup directory created in Step 6.

8. Copy entrypoint.sh from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/entrypoint.sh.

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/ic/entrypoint.sh
   ```

9. Make the entrypoint.sh script executable.

   ```
   $ chmod u+x entrypoint.sh
   ```
   
10. At this point, you should have the following directories/files:

    - ~/images/db2/ic/Dockerfile
    - ~/images/db2/ic/env.txt
    - ~/images/db2/ic/setup/entrypoint.sh
   
11. Change directories to the directory created in Step 1. For example, ~/images/db2/ic.

12. Build the image.

    ```
    $ docker build -t db2/11.1.1/ic .
    ```
    
13. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
You have now successfully created the DB2 for Connections image. For next steps, review the documentation for running a 
[DB2 for Connections container](doc/containers/db2_ic.md).