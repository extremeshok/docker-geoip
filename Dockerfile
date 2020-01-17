FROM extremeshok/baseimage-alpine:latest AS BUILD

LABEL mantainer="Adrian Kriel <admin@extremeshok.com>" vendor="eXtremeSHOK.com"

RUN \
  echo "**** install bash runtime packages ****" \
  && apk-install \
    bash \
    coreutils \
    curl \
    file \
    rsync \
    unzip

# add local files
COPY rootfs/ /

RUN \
  echo "**** configure ****" \
  && chmod 777 /xshok-geoip.sh

WORKDIR /tmp

ENTRYPOINT ["/init"]
