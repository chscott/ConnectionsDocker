FROM centos

LABEL maintainer="chads@us.ibm.com"

WORKDIR /setup

COPY setup /setup

# Install the TDI prereqs
RUN yum install -y \
    libstdc++.so.6 \
    unzip \
    which \
    && yum clean all