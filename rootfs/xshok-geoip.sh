#!/usr/bin/env bash

################################################################################
# This is property of eXtremeSHOK.com
# You are free to use, modify and distribute, however you may not remove this notice.
# Copyright (c) Adrian Jon Kriel :: admin@extremeshok.com
################################################################################

# db-ip.com lite replaces Maxmind GeoIP v2
REPLACE_MAXMIND=${REPLACE_MAXMIND:-yes}

# DEFAULTS
DISABLE_DBIP=${DISABLE_DBIP:-no}
DISABLE_MAXMIND=${DISABLE_MAXMIND:-yes}
DISABLE_LEGACY=${DISABLE_LEGACY:-yes}
DISABLE_COUNTRY_CIDR=${DISABLE_COUNTRY_CIDR:-no}

if [ "$REPLACE_MAXMIND" == "yes" ] || [ "$REPLACE_MAXMIND" == "true" ] || [ "$REPLACE_MAXMIND" == "on" ] || [ "$REPLACE_MAXMIND" == "1" ] ; then
  DISABLE_MAXMIND="yes"
fi

if [ "$DISABLE_DBIP" != "yes" ] && [ "$DISABLE_DBIP" != "true" ] && [ "$DISABLE_DBIP" != "on" ] && [ "$DISABLE_DBIP" != "1" ] ; then

  echo "========== Updating DB-IP Databases =========="

  mkdir -p /tmp/dbip
  cd /tmp || exit

  if [ -f "/tmp/dbip-country-lite.mmdb.gz" ]; then
    curl -o /tmp/dbip-country-lite.mmdb.gz -z /tmp/dbip-country-lite.mmdb.gz -L "https://download.db-ip.com/free/dbip-country-lite-$(date +%Y-%m).mmdb.gz"
  else
    curl -o /tmp/dbip-country-lite.mmdb.gz -L "https://download.db-ip.com/free/dbip-country-lite-$(date +%Y-%m).mmdb.gz"
  fi
  if [ -f "/tmp/dbip-city-lite.mmdb.gz" ]; then
    curl -o /tmp/dbip-city-lite.mmdb.gz -z /tmp/dbip-city-lite.mmdb.gz -L "https://download.db-ip.com/free/dbip-city-lite-$(date +%Y-%m).mmdb.gz"
  else
    curl -o /tmp/dbip-city-lite.mmdb.gz -L "https://download.db-ip.com/free/dbip-city-lite-$(date +%Y-%m).mmdb.gz"
  fi

  for i in dbip-*.mmdb.gz ; do
    gzip -dkc < $i > /tmp/dbip/${i%%.gz}
  done

  mkdir -p /geoip/dbip
  rsync_output="$(rsync -rtv --delete --delete-excluded --recursive /tmp/dbip/ /geoip/dbip/ --include "*.mmdb" --exclude "*.*" --exclude "GeoLite2-*" )"
  echo "$rsync_output"

  if [ "$REPLACE_MAXMIND" == "yes" ] || [ "$REPLACE_MAXMIND" == "true" ] || [ "$REPLACE_MAXMIND" == "on" ] || [ "$REPLACE_MAXMIND" == "1" ] ; then
    echo "DB-IP.org replacing Maxmind GeoIPv2"
    DISABLE_MAXMIND="yes"


    ln -s /tmp/dbip/dbip-city-lite.mmdb /tmp/dbip/GeoLite2-City.mmdb
    ln -s /tmp/dbip/dbip-country-lite.mmdb /tmp/dbip/GeoLite2-Country.mmdb

    mkdir -p /geoip/maxmind
    rsync_output="$(rsync -rtv --delete --delete-excluded --recursive /tmp/dbip/ /geoip/maxmind/ --include "*.mmdb" --exclude "*.*" --exclude "dbip-*")"
    echo "$rsync_output"
  fi

fi

if [ "$DISABLE_MAXMIND" != "yes" ] && [ "$DISABLE_MAXMIND" != "true" ] && [ "$DISABLE_MAXMIND" != "on" ] && [ "$DISABLE_MAXMIND" != "1" ] ; then
  echo "========== Updating Maxmind GeoIPv2 Databases =========="
  mkdir -p /geoip/maxmind
  cat << EOF > /etc/geoip.conf
AccountID ${ACCOUNT_ID:-"0"}
LicenseKey ${LICENSE_KEY:-"000000000000"}
EditionIDs ${EDITION_IDS:-"GeoLite2-City GeoLite2-Country"}

# The remaining settings are OPTIONAL.

# The directory to store the database files. Defaults to /usr/local/share/GeoIP
DatabaseDirectory /geoip/maxmind

# The server to use. Defaults to "updates.maxmind.com".
Host ${MAXMIND_HOST:-"updates.maxmind.com"}

# The desired protocol either "https" (default) or "http".
Protocol ${PROTOCOL:-"https"}

# The proxy host name or IP address. You may optionally specify a
# port number, e.g., 127.0.0.1:8888. If no port number is specified, 1080
# will be used.
# Proxy 127.0.0.1:8888

# The user name and password to use with your proxy server.
# ProxyUserPassword username:password

# Whether to skip host name verification on HTTPS connections.
# Defaults to "0".
SkipHostnameVerification ${SKIP_HOSTNAME_VERIFICATION:-"0"}

# Whether to skip peer verification on HTTPS connections.
# Defaults to "0".
SkipPeerVerification ${SKIP_PEER_VERIFICATION:-"0"}

EOF

  geoipupdate -v -f /etc/geoip.conf -d /geoip/maxmind
  #clean lockfile
  rm -f /usr/share/GeoIP/.geoipupdate.lock
fi

if [ "$DISABLE_LEGACY" != "yes" ] && [ "$DISABLE_LEGACY" != "true" ] && [ "$DISABLE_LEGACY" != "on" ] && [ "$DISABLE_LEGACY" != "1" ] ; then
  echo "========== Updating GeoIP Legacy Databases from  https://www.miyuru.lk/geoiplegacy =========="

  mkdir -p /tmp/legacy
  cd /tmp || exit

  if [ -f "/tmp/dbip-country.dat.gz" ]; then
    curl -o /tmp/dbip-country.dat.gz -z /tmp/GeoIP.dat.gz -L "https://dl.miyuru.lk/geoip/dbip/country/dbip.dat.gz"
  else
    curl -o /tmp/dbip-country.dat.gz -L "https://dl.miyuru.lk/geoip/dbip/country/dbip.dat.gz"
  fi
  if [ -f "/tmp/dbip-city.dat.gz" ]; then
    curl -o /tmp/dbip-city.dat.gz -z /tmp/dbip-city.dat.gz -L "https://dl.miyuru.lk/geoip/dbip/city/dbip.dat.gz"
  else
    curl -o /tmp/dbip-city.dat.gz -L "https://dl.miyuru.lk/geoip/dbip/city/dbip.dat.gz"
  fi

  for i in dbip-*.dat.gz ; do
    gzip -dkc < $i > /tmp/legacy/${i%%.gz}
  done

  mkdir -p /geoip/legacy
  rsync_output="$(rsync -rtv --delete --delete-excluded --recursive /tmp/legacy/ /geoip/legacy/ --include "*.dat" --exclude "*.*" --exclude "GeoIP*" --exclude "GeoLiteCity*" )"
  echo "$rsync_output"

  if [ "$REPLACE_MAXMIND" == "yes" ] || [ "$REPLACE_MAXMIND" == "true" ] || [ "$REPLACE_MAXMIND" == "on" ] || [ "$REPLACE_MAXMIND" == "1" ] ; then
    echo "DB-IP.org replacing Maxmind GeoIPv2"
    DISABLE_MAXMIND="yes"

    ln -s /tmp/legacy/dbip-city.dat /tmp/legacy/GeoLiteCity.dat
    ln -s /tmp/legacy/dbip-country.dat /tmp/legacy/GeoIP.dat

    mkdir -p /geoip/maxmind-legacy
    rsync_output="$(rsync -rtv --delete --delete-excluded --recursive /tmp/legacy/ /geoip/maxmind-legacy/ --include "*.dat" --exclude "*.*" --exclude "dbip-*")"
    echo "$rsync_output"
  fi
fi

if [ "$DISABLE_COUNTRY_CIDR" != "yes" ] && [ "$DISABLE_COUNTRY_CIDR" != "true" ] && [ "$DISABLE_COUNTRY_CIDR" != "on" ] && [ "$DISABLE_COUNTRY_CIDR" != "1" ] ; then
  mkdir -p /geoip/country-cidr
  echo "========== Updating nginx-countries =========="
  mkdir -p /tmp/nginx-countries
  mkdir -p /geoip/nginx-countries
  if [ -f "/tmp/nginx-countries.zip" ]; then
    curl -o /tmp/nginx-countries.zip -z /tmp/nginx-countries.zip -L https://firewalliplists.gypthecat.com/lists/nginx/nginx-countries.conf.zip
  else
    curl -o /tmp/nginx-countries.zip -L https://firewalliplists.gypthecat.com/lists/nginx/nginx-countries.conf.zip
  fi
  unzip -q -o -j /tmp/nginx-countries.zip -d /tmp/nginx-countries
  rsync -W -h -r -L -p -t -g -o -i --prune-empty-dirs --delete --delete-excluded --no-compress "/tmp/nginx-countries/" "/geoip/country-cidr"
fi


echo "========== SLEEPING for 1 day =========="
sleep 1d
