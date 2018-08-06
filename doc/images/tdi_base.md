## TDI base image

In this guide, we'll walk through creating a Docker image for TDI. This image will contain an installed TDI server that will 
serve as the base image for a TDI for Connections image.

### Steps
   
1. On the Docker host system, create a directory to hold the image artifacts. For this guide, we'll use ~/images/tdi/base.

2. Change to the ~/images/tdi/base directory.

3. Download the Dockerfile from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/Dockerfile. 

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/Dockerfile
   ```
   
4. Create the ~/images/tdi/base/setup directory.
   
5. Change to the ~/images/tdi/base/setup directory.

6. Download entrypoint.sh from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/entrypoint.sh.

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/entrypoint.sh
   ```

7. Make the entrypoint.sh script executable.

   ```
   $ chmod u+x entrypoint.sh
   ```
   
8. At this point, you should have the following directories/files:

   - ~/images/tdi/base/Dockerfile
   - ~/images/tdi/base/setup/entrypoint.sh
   
9. Change to the ~/images/tdi/base directory.

10. Build the image.

    ```
    $ docker build -t tdi/7.1.1.6/preinstall .
    ```
    
11. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
12. Change to the home directory and download env-tdi-base.txt.
   
    ```
    $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/env-tdi-base.txt
    ```
   
13. Open env-tdi-base.txt and update the URLs for your environment. These are the locations at which the TDI install and 
    fixpack packages plus the required DB2 JARs are hosted in your environment. These files will be downloaded during 
    installation.
    
14. Run a container based on the new TDI base image.

    ```
    $ docker run --name tdi_install --env-file ~/env-tdi-base.txt -it tdi/7.1.1.6/preinstall
    ```
    
15. Run the entrypoint.sh script and confirm TDI installs successfully.

    ```
    $ ./entrypoint.sh
    ```
        
16. Delete the /setup directory inside the container. This directory holds installation artifacts that are not needed moving
    forward. Deleting them now reduces the size of the image we are about to create.
    
    ```
    $ cd /
    $ rm -f -r /setup
    ```
    
17. Exit the container shell.

    ```
    $ exit
    ```
    
18. Commit the changes made to the tdi_install container to a new image.

    ```
    $ docker commit tdi_install tdi/7.1.1.6/base
    ```
    
19. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
20. Remove the tdi_install container, as it is no longer needed.

    ```
    $ docker container rm tdi_install
    ```
    
21. Remove the preinstall image, as it is no longer needed.

    ```
    $ docker image rm tdi/7.1.1.6/preinstall
    ```
    
You have now successfully created the TDI base image.