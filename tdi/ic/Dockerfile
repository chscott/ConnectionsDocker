FROM tdi/7.1.1.6/base

VOLUME ["/data"]

ENV TDI_SOLDIR /app

WORKDIR /setup

COPY setup /setup

ENTRYPOINT ["./entrypoint.sh"]
