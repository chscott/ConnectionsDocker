## DB2 base image

In this guide, we'll walk through creating a Docker image for DB2. This image will contain an installed DB2 server that will 
serve as the base image for a DB2 for Connections image.

Note that this image uses centos/systemd as its own base image. This is required due to a dependency in the DB2 installer. If 
systemd is not available, the DB2 fault manager component will fail to install, causing the entire DB2 installation to fail.

### Steps

1. On the Docker host system, create a directory to hold the image artifacts. For this guide, we'll use ~/images/db2/base.

2. Change to the ~/images/db2/base directory.

3. Download the Dockerfile from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/Dockerfile. 

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/Dockerfile
   ```
   
4. Create the ~/images/db2/base/setup directory.
   
5. Change to the ~/images/db2/base/setup directory.

6. Download entrypoint.sh from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/entrypoint.sh.

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/entrypoint.sh
   ```

7. Make the entrypoint.sh script executable.

   ```
   $ chmod u+x entrypoint.sh
   ```
   
8. At this point, you should have the following directories/files:

   - ~/images/db2/base/Dockerfile
   - ~/images/db2/base/setup/entrypoint.sh
   
9. Change to the ~/images/db2/base directory.

10. Build the image.

    ```
    $ docker build -t db2/11.1.1/preinstall .
    ```
    
11. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
12. Change to the home directory and download env-db2-base.txt from 
    https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/env-db2-base.txt.
   
   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/env-db2-base.txt
   ```
   
13. Open env-db2-base.txt and update the URLs for your environment. These are the locations at which the DB2 install and 
    license packages are hosted in your environment. These files will be downloaded during installation.
   
14. Run a container based on the new DB2 base image.

    ```
    $ docker run --name db2_install --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:ro --env-file ~/env-db2-base.txt -d db2/11.1.1/preinstall
    ```
    
15. Start a shell in the running container.

    ```
    $ docker exec -it db2_install bash
    ```
    
16. Run the entrypoint.sh script.

    ```
    $ ./entrypoint.sh
    ```
    
17. Confirm DB2 has installed successfully.

18. Delete the /setup directory inside the container. This directory holds installation artifacts that are not needed moving
    forward. Deleting them now reduces the size of the image we are about to create.
    
    ```
    $ cd /
    $ rm -f -r /setup
    ```
    
19. Exit the container shell.

    ```
    $ exit
    ```
 
20. Stop the db2_install container.

    ```
    $ docker stop db2_install
    ```
    
21. Commit the changes made to the db2_install container to a new image.

    ```
    $ docker commit db2_install db2/11.1.1/base
    ```
    
22. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
23. Remove the db2_install container, as it is no longer needed.

    ```
    $ docker container rm db2_install
    ```
    
24. Remove the preinstall image, as it is no longer needed.

    ```
    $ docker image rm db2/11.1.1/preinstall
    ```

25. Delete env-db2-base.txt, as it is no longer needed.

    ```
    $ rm ~/env-db2-base.txt
    ```
    
You have now successfully created the DB2 base image.