FROM db2/11.1.1/base

EXPOSE 50000

VOLUME ["/data"]

WORKDIR /setup

COPY setup /setup

ENTRYPOINT ["./entrypoint.sh"]
