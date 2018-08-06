## TDI for Connections image

In this guide, we'll walk through creating a Docker TDI image for Connections. This image inherits the installed TDI server
via the [TDI base image](tdi_base.md) and adds additional run-time artifacts to create an instance for use with 
Connections. All configuration steps from the documentation are performed automatically, including the configuration of the
TDI solution directory.

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
 
4. Open env.txt and update the URLs for your environment. These are the locations at which the Connections database wizard
   and CR1/CR2 update packages are hosted in your environment. Only the database wizard package is required. 
   
   - If you want to install the Connections databases at 6.0 base release level, leave the CR1 and CR2 update URLs commented 
     out. 
   
   - If you want to install the Connections databases at 6.0 CR1 release level, uncomment the CR1 update URL. 
   
   - If you want to install the Connections databases at 6.0 CR2 release level, uncomment the CR2 update URL. 
   
   These files will be downloaded during the initialization process.
   
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
    $ docker build -t tdi/11.1.1/ic .
    ```
    
15. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
You have now successfully created the TDI for Connections image. For next steps, review the documentation for running a 
[TDI for Connections container](../containers/tdi_ic.md).