## DB2 base image

In this guide, we'll walk through creating a Docker image for DB2. This image will contain an installed DB2 server that will 
serve as the base image for a DB2 for Connections image.

Note that this image uses centos/systemd as its own base image. This is required due to a dependency in the DB2 installer. If 
systemd is not available, the DB2 fault manager component will fail to install, causing the entire DB2 installation to fail.

### Steps

1. On the Docker host system, create a directory to hold the image artifacts. For this guide, we'll use ~/images/db2/base.

2. Change to the ~/images/db2/base directory.

3. Download env.txt from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/env.txt.
   
   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/env.txt
   ```
   
4. Open env.txt and update the URLs for your environment. These are the locations at which the DB2 install and license
   packages are hosted in your environment. These files will be downloaded during installation.
   
5. Create the ~/images/db2/base/image directory.

6. Change to the ~/images/db2/base/image directory.

7. Download the Dockerfile from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/Dockerfile. 

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/Dockerfile
   ```
   
8. Create the ~/images/db2/base/image/setup directory.
   
9. Change to the ~/images/db2/base/image/setup directory.

10. Download entrypoint.sh from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/entrypoint.sh.

    ```
    $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/entrypoint.sh
    ```

11. Make the entrypoint.sh script executable.

    ```
    $ chmod u+x entrypoint.sh
    ```
   
12. At this point, you should have the following directories/files:

    - ~/images/db2/base/env.txt
    - ~/images/db2/base/image/Dockerfile
    - ~/images/db2/base/image/setup/entrypoint.sh
   
13. Change to the ~/images/db2/base/image directory.

14. Build the image.

    ```
    $ docker build -t db2/11.1.1/preinstall .
    ```
    
15. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
16. Run a container based on the new DB2 base image.

    ```
    $ docker run --name db2_install --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:ro --env-file ~/images/db2/base/env.txt -d db2/11.1.1/preinstall
    ```
    
17. Start a shell in the running container.

    ```
    $ docker exec -it db2_install bash
    ```
    
18. Run the entrypoint.sh script.

    ```
    $ ./entrypoint.sh
    ```
    
19. Confirm DB2 has installed successfully by reviewing db2_install.log in the current directory in the container.

20. Delete the /setup directory inside the container. This directory holds installation artifacts that are not needed moving
    forward. Deleting them now reduces the size of the image we are about to create.
    
    ```
    $ cd /
    $ rm -f -r /setup
    ```
    
21. Exit the container shell.

    ```
    $ exit
    ```
 
22. Stop the db2_install container.

    ```
    $ docker stop db2_install
    ```
    
23. Commit the changes made to the db2_install container to a new image.

    ```
    $ docker commit db2_install db2/11.1.1/base
    ```
    
24. Confirm the image was created successfully.

    ```
    $ docker image ls
    ```
    
25. Remove the db2_install container, as it is no longer needed.

    ```
    $ docker container rm db2_install
    ```
    
26. Remove the preinstall image, as it is no longer needed.

    ```
    $ docker image rm db2/11.1.1/preinstall
    ```
    
You have now successfully created the DB2 base image.