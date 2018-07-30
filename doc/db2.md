## DB2 base image

In this guide, we'll walk through creating a Docker image for DB2. This image will later serve as the base image for our DB2
for Connections image.

Note that this image uses centos/systemd as its base image. This is required due to a dependency in the DB2 installer. If 
systemd is not available, the fault manager component will fail to install, causing the entire DB2 installation to fail.

### Steps

1. On the Docker host system, create a directory to hold the image artifacts. For example, ~/images/db2/base.

2. Change directories to the directory created in Step 1.

3. Copy the Dockerfile from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/Dockerfile. 

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/Dockerfile
   ```
   
4. Copy env.txt from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/env.txt.
   
   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/env.txt
   ```
5. Open env.txt and update the URLs for your environment. These are the locations at which the DB2 install and license
   packages are hosted in your environment. These files will be downloaded during installation.
   
6. Create a subdirectory named setup. If you used the example directory in Step 1, it will be located at 
   ~/images/db2/base/setup.
   
7. Change directories to the setup directory created in Step 6.

8. Copy entrypoint.sh from https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/entrypoint.sh.

   ```
   $ curl -L -O -J -s -S -f https://raw.githubusercontent.com/chscott/ConnectionsDocker/master/db2/base/Dockerfile
   ```
   
9. At this point, you should have the following directories/files:

   ~/images/db2/base/Dockerfile
   ~/images/db2/base/env.txt
   ~/images/db2/base/setup/entrypoint.sh
   
10. 