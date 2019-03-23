#!/usr/bin/env bash

echo "========== Updating Maxmind GeoIPv2 Databases =========="
mkdir -p /geoip/maxmind
mkdir -p /geoip/country-cidr
mkdir -p /geoip/maxmind-legacy

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

# echo "========== Updating Maxmind GeoIP Legacy Databases =========="
if [ ! -f "/usr/share/GeoIP/GeoIPCity.dat" ] ; then
  cp -f /usr/share/GeoIP/GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat
fi
# Deprecated, now we include the last available version
rsync -W -h -r -L -p -t -g -o -i --prune-empty-dirs --delete --delete-excluded --no-compress  "/usr/share/GeoIP/" "/geoip/maxmind-legacy/"

# mkdir -p /tmp/maxmind-legacy
#
# if [ -f "/tmp/maxmind-legacy/GeoIP.dat.gz" ] && [ -f "/geoip/maxmind/GeoIP.dat" ]; then
#   curl -o /tmp/maxmind-legacy/GeoIP.dat.gz -z /tmp/maxmind-legacy/GeoIP.dat.gz -L http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
# else
#   curl -o /tmp/maxmind-legacy/GeoIP.dat.gz -L http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
# fi
# gunzip /tmp/maxmind-legacy/GeoIP.dat.gz
#
# if [ -f "/tmp/maxmind-legacy/GeoLiteCity.dat.gz" ] && [ -f "/geoip/maxmind/GeoLiteCity.dat" ]; then
#   curl -o /tmp/maxmind-legacy/GeoLiteCity.dat.gz -z /tmp/maxmind-legacy/GeoLiteCity.dat.gz -L http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
# else
#   curl -o /tmp/maxmind-legacy/GeoLiteCity.dat.gz -L http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
# fi
# gunzip /tmp/maxmind-legacy/GeoLiteCity.dat.gz

#rsync -W -h -r -L -p -t -g -o -i --prune-empty-dirs --exclude "*.mmdb" --no-compress "/tmp/maxmind-legacy/" "/geoip/maxmind/"

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
