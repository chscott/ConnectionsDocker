## TDI base image

In this guide, we'll walk through creating a Docker image for TDI. This image will contain an installed TDI server that will 
serve as the base image for a TDI for Connections image.

### Steps

1. On the Docker host system, create a directory to hold the image artifacts. For this guide, we'll use ~/images/tdi/base.

2. Change to the ~/images/tdi/base directory.

3. Download env.txt from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/env.txt.
   
   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/env.txt
   ```
   
4. Open env.txt and update the URLs for your environment. These are the locations at which the TDI install and fixpack
   packages plus the required DB2 JARs are hosted in your environment. These files will be downloaded during installation.
   
5. Create the ~/images/tdi/base/image directory.

6. Change to the ~/images/tdi/base/image directory.

7. Download the Dockerfile from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/Dockerfile. 

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/Dockerfile
   ```
   
8. Create the ~/images/tdi/base/image/setup directory.
   
9. Change to the ~/images/tdi/base/image/setup directory.

10. Download entrypoint.sh from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/entrypoint.sh.

    ```
    $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/tdi/base/entrypoint.sh
    ```

11. Make the entrypoint.sh script executable.

    ```
    $ chmod u+x entrypoint.sh
    ```
   
12. At this point, you should have the following directories/files:

    - ~/images/tdi/base/env.txt
    - ~/images/tdi/base/image/Dockerfile
    - ~/images/tdi/base/image/setup/entrypoint.sh
   
13. Change to the ~/images/tdi/base/image directory.

14. Build the image.

    ```
    $ docker build -t tdi/11.1.1/preinstall .
    ```
    
15. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
16. Run a container based on the new TDI base image.

    ```
    $ docker run --name tdi_install --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:ro --env-file ~/images/tdi/base/env.txt -d tdi/11.1.1/preinstall
    ```
    
17. Follow the container logs to monitor progress of the TDI installation.

    ```
    $ docker logs --follow tdi_install
    ```
    
18. Confirm TDI has installed successfully by reviewing tdi_install.log in the current directory in the container.

19. Delete the /setup directory inside the container. This directory holds installation artifacts that are not needed moving
    forward. Deleting them now reduces the size of the image we are about to create.
    
    ```
    $ cd /
    $ rm -f -r /setup
    ```
    
20. Exit the container shell.

    ```
    $ exit
    ```
 
21. Stop the tdi_install container.

    ```
    $ docker stop tdi_install
    ```
    
22. Commit the changes made to the tdi_install container to a new image.

    ```
    $ docker commit tdi_install tdi/11.1.1/base
    ```
    
23. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
24. Remove the tdi_install container, as it is no longer needed.

    ```
    $ docker container rm tdi_install
    ```
    
25. Remove the preinstall image, as it is no longer needed.

    ```
    $ docker image rm tdi/11.1.1/preinstall
    ```
    
You have now successfully created the TDI base image.