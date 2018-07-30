# Base image requires systemd due to DB2 installer dependency
FROM centos/systemd

LABEL maintainer="chads@us.ibm.com"

WORKDIR /setup

COPY setup /setup

# Install the DB2 prereqs
RUN yum install -y \
    file \
    libaio \
    libstdc++.so.6 \
    ncurses-libs.i686 \
    numactl-libs \
    pam.i686 \
    unzip \
    && yum clean all
