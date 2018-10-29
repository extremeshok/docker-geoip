#!/bin/bash
echo "========== Updating Maxmind GeoIPv2 Databases =========="
mkdir -p /geoip/maxmind
geoipupdate -v -d /geoip/maxmind

echo "========== Updating Maxmind GeoIP Legacy Databases =========="
mkdir -p /tmp/maxmind-legacy

if [ -f "/tmp/maxmind-legacy/GeoIP.dat.gz" ] && [ -f "/geoip/maxmind/GeoIP.dat" ]; then
  curl -o /tmp/maxmind-legacy/GeoIP.dat.gz -z /tmp/maxmind-legacy/GeoIP.dat.gz -L http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
else
  curl -o /tmp/maxmind-legacy/GeoIP.dat.gz -L http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
fi
gunzip /tmp/maxmind-legacy/GeoIP.dat.gz

if [ -f "/tmp/maxmind-legacy/GeoLiteCity.dat.gz" ] && [ -f "/geoip/maxmind/GeoLiteCity.dat" ]; then
  curl -o /tmp/maxmind-legacy/GeoLiteCity.dat.gz -z /tmp/maxmind-legacy/GeoLiteCity.dat.gz -L http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
else
  curl -o /tmp/maxmind-legacy/GeoLiteCity.dat.gz -L http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
fi
gunzip /tmp/maxmind-legacy/GeoLiteCity.dat.gz

rsync -W -h -r -L -p -t -g -o -i --prune-empty-dirs --exclude "*.mmdb" --no-compress "/tmp/maxmind-legacy/" "/geoip/maxmind/"

echo "========== Updating nginx-countries =========="
mkdir -p /tmp/nginx-countries
mkdir -p /geoip/nginx-countries
if [ -f "/tmp/nginx-countries.zip" ]; then
  curl -o /tmp/nginx-countries.zip -z /tmp/nginx-countries.zip -L https://firewalliplists.gypthecat.com/lists/nginx/nginx-countries.conf.zip
else
  curl -o /tmp/nginx-countries.zip -L https://firewalliplists.gypthecat.com/lists/nginx/nginx-countries.conf.zip
fi
unzip -q -o -j /tmp/nginx-countries.zip -d /tmp/nginx-countries
rsync -W -h -r -L -p -t -g -o -i --prune-empty-dirs --delete --delete-excluded --no-compress "/tmp/nginx-countries/" "/geoip/country-cidr/"

echo "========== SLEEPING for 1 day =========="
sleep 1d
