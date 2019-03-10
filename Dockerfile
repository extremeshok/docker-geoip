FROM extremeshok/baseimage-alpine:latest AS BUILD

LABEL mantainer="Adrian Kriel <admin@extremeshok.com>" vendor="eXtremeSHOK.com"

RUN \
  echo "**** install bash runtime packages ****" \
  && apk-install \
    bash \
    coreutils \
    curl \
    file \
    openssh-client \
    rsync \
    unzip

RUN \
  echo "**** install build packages ****" \
  && apk-install build-base \
  git \
  go

ENV GEOIP_CONF_FILE /etc/geoip.conf
ENV GEOIP_DB_DIR /geoip/maxmind

RUN \
  echo "**** install geoipupdate ****" \
  && THISVERSION="$(curl --silent "https://api.github.com/repos/maxmind/geoipupdate/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')" \
  && THISVERSION="$(echo "$THISVERSION" | sed 's/v//')" \
  && echo "$THISVERSION" \
  && go get -u github.com/maxmind/geoipupdate/cmd/geoipupdate \
  && mv /root/go/bin/geoipupdate /bin/geoipupdate \
  && rm -rf /root/go/

RUN \
  echo "**** remove build packages ****" \
  && apk del --purge  build-base  \
  git

# add local files
COPY rootfs/ /

RUN \
  echo "**** configure ****" \
  && chmod 777 /xshok-geoip.sh

WORKDIR /tmp

ENTRYPOINT ["/init"]
