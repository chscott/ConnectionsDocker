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
      
3. Copy the Dockerfile from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/Dockerfile. 

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/Dockerfile
   ```  
   
4. Create the ~/images/tdi/ic/setup directory.
   
5. Change to the ~/images/tdi/ic/setup directory.
   
6. Download entrypoint.sh from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/entrypoint.sh.

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/ic/entrypoint.sh
   ```

7. Make the entrypoint.sh script executable.

   ```
   $ chmod u+x entrypoint.sh
   ```
   
8. At this point, you should have the following directories/files:

   - ~/images/tdi/ic/Dockerfile
   - ~/images/tdi/ic/setup/entrypoint.sh
   
9. Change to the ~/images/tdi/ic directory.

10. Build the image.

    ```
    $ docker build -t tdi/7.1.1.6/ic .
    ```
    
11. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
You have now successfully created the TDI for Connections image. For next steps, review the documentation for running a 
[TDI for Connections container](../containers/tdi_ic.md).