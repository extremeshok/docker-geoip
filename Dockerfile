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
    zlib-dev \
    curl-dev

RUN \
  echo "**** install geoipupdate ****" \
  && THISVERSION="$(curl --silent "https://api.github.com/repos/maxmind/geoipupdate/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')" \
  && echo "$THISVERSION" \
  && THISVERSION="$(echo "$THISVERSION" | sed 's/v//')" \
  && curl --silent -o /tmp/geoipupdate.tar.gz -L \
   "https://github.com/maxmind/geoipupdate/releases/download/v${THISVERSION}/geoipupdate-${THISVERSION}.tar.gz" \
  && mkdir -p /tmp/geoipupdate \
  && tar xfz /tmp/geoipupdate.tar.gz -C /tmp/geoipupdate \
  && cd /tmp/geoipupdate/geoipupdate* \
  && ./configure \
  && make \
  && make install \
  && rm -rf /tmp/geoipupdate \
  && rm -f /tmp/geoipupdate.tar.gz

RUN \
  echo "**** remove build packages ****" \
  && apk del --purge build-base \
    zlib-dev \
    curl-dev

# add local files
COPY rootfs/ /

RUN \
  echo "**** configure ****" \
  && chmod 777 /xshok-geoip.sh

WORKDIR /tmp

ENTRYPOINT ["/init"]
