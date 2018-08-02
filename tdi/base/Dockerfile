FROM centos

LABEL maintainer="chads@us.ibm.com"

WORKDIR /setup

COPY setup /setup

RUN yum install -y unzip

ENTRYPOINT ["./entrypoint.sh"]